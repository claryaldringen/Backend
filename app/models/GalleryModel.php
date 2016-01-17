<?php

class GalleryModel extends BaseModel{

	/** @var NameModel */
	protected $nameModel;

	protected $gallery = array();

	protected $sharedToSave = array();

	protected $uploadedFilesInfo = array();

	public function __construct(ConfigurationModel $config, NameModel $nameModel)
	{
		parent::__construct($config);
		$this->nameModel = $nameModel;
	}

	public function getFolders($menuId, $showType = 'all') {
		if(!isset($this->gallery[$menuId])) {
			$tree = $folderIds = array();

			$sql = "SELECT f.id,f.folder_id AS parent,t.text AS name,IF(t2.text IS NULL, '', t2.text) AS text,t.url FROM folder f
				JOIN menu_has_folder mhf ON mhf.folder_id=f.id
				LEFT JOIN name_has_text nht ON f.name_id=nht.name_id AND nht.language_id=%i
				LEFT JOIN [text] t ON t.id=nht.text_id
				LEFT JOIN folder_has_name fhn ON fhn.folder_id=f.id
				LEFT JOIN name_has_text nht2 ON fhn.name_id=nht2.name_id AND nht2.language_id=%i
				LEFT JOIN [text] t2 ON t2.id=nht2.text_id
				WHERE menu_id=%i GROUP BY id ORDER BY f.folder_id,sort_key,f.id";

			$rows = $this->db->query($sql, $this->getLanguageId(), $this->getLanguageId(), $menuId)->fetchAll();
			foreach ($rows as $key => $row) {
				$folderIds[] = $row->id;
				if ($key == 0) {
					$tree[] = $row->toArray();
				} else {
					$this->addFolder($tree, $row->toArray());
				}
			}

			$mime = '';
			if($showType != 'all') $mime = "AND i.type='$showType'";

			$sql = "SELECT i.id,IF(type = 'image', CONCAT(i.hash, '.', i.mime),i.hash) AS file,folder_id AS parent,[text] AS name,i.type
			FROM [image] i
			LEFT JOIN [name_has_text] nht ON i.name_id=nht.name_id AND language_id=%i
			LEFT JOIN [text] t ON t.id=nht.text_id
			WHERE folder_id IN %in $mime ORDER BY sort_key,id";

			$rows = $this->db->query($sql, $this->getLanguageId(), $folderIds)->fetchAll();
			foreach ($rows as $key => $row) {
				$this->addImage($tree, $row->toArray());
			}

			$this->gallery[$menuId] = $tree;
		}
		return $this->gallery[$menuId];
	}

	private function addFolder(&$tree, $folder) {
		foreach($tree as &$branch) {
			if($branch['id'] == $folder['parent']) {
				if(!isset($branch['folders'])) {
					$branch['folders'] = array($folder);
				} else {
					$branch['folders'][] = $folder;
				}
				return true;
			} elseif(isset($branch['folders'])) {
				if($this->addFolder($branch['folders'], $folder)) return true;
			}
		}
		return false;
	}

	private function addImage(&$tree, $image) {
		foreach($tree as &$branch) {
			if($branch['id'] == $image['parent']) {
				if(!isset($branch['images'])) {
					$branch['images'] = array($image);
				} else {
					$branch['images'][] = $image;
				}
				return true;
			} elseif(isset($branch['folders'])) {
				if($this->addImage($branch['folders'], $image)) return true;
			}
		}
		return false;
	}

	public function createFolder($folderId, $menuId, $name = 'Nová složka') {
		$this->db->begin();
		try {
			$nameId = NULL;
			if(!empty($name)) $nameId = $this->nameModel->setName($name, 'folder');
			$this->db->query("INSERT INTO [folder] ", array('folder_id' => $folderId, 'name_id' => $nameId));

			$insert = array();
			$id = $this->db->getInsertId();
			$menuIds = $this->db->query("SELECT menu_id FROM menu_has_folder WHERE folder_id=%i", $folderId)->fetchPairs(NULL, 'menu_id');
			if(empty($menuIds)) $menuIds = array($menuId);
			foreach($menuIds as $menuId) {
				$insert[] = array('menu_id' => $menuId, 'folder_id' => $id);
			}

			$this->db->query("INSERT INTO [menu_has_folder] %ex", $insert);
		}catch (Exception $ex) {
			$this->db->rollback();
			throw $ex;
		}
		$this->db->commit();
		return $this;
	}

	public function setFolderName($id, $name)
	{
		$this->db->begin();
		try {
			$nameId = $this->nameModel->setName($name, 'folder');
			$this->db->query("UPDATE [folder] SET name_id=%i WHERE id=%i", $nameId, $id);
			$this->nameModel->clear('folder');
		} catch(Exception $ex) {
			$this->db->rollback();
			throw $ex;
		}
		$this->db->commit();
		return $this;
	}

	public function setImageName($id, $name) {
		$this->db->begin();
		try {
			$nameId = $this->nameModel->setName($name, 'image');
			$this->db->query("UPDATE [image] SET name_id=%i WHERE id=%i", $nameId, $id);
			$this->nameModel->clear('image');
		} catch(Exception $ex) {
			$this->db->rollback();
			throw $ex;
		}
		$this->db->commit();
		return $this;
	}

	public function saveImages(array $files, $folderId) {
		$this->uploadedFilesInfo = array();
		foreach($files['files'] as $file) {
			$parts = explode('.', $file->name);
			$mime = end($parts);

			if($file->isImage()) {
				$image = $file->toImage();
				$hash = md5($file->getContents());
				$this->db->begin();
				try {
					$nameId = $this->nameModel->setName($file->getName(), 'image');
					$sortKey = $this->db->query("SELECT sort_key FROM image WHERE folder_id=%i ORDER BY sort_key DESC LIMIT 1", $folderId)->fetchSingle();
					$this->db->query("INSERT INTO [image]", array('folder_id' => $folderId, 'name_id' => $nameId, 'hash' => $hash, 'mime' => $mime, 'type' => 'image','sort_key' => ++$sortKey));
					$this->uploadedFilesInfo[] = array('id' => $this->db->getInsertId(), 'hash' => $hash);

					$image->save('./images/userimages/original/' . $hash . '.jpg');
					$sizes = array(
						array('path' => './images/userimages/large', 'width' => 1024, 'height' => 768),
						array('path' => './images/userimages/medium', 'width' => 240, 'height' => 180),
						array('path' => './images/userimages/small', 'width' => 128, 'height' => 96),
					);
					foreach ($sizes as $size) {
						if ($image->width > $size['width'] || $image->height > $size['height']) $image->resize($size['width'], $size['height']);
						$image->save($size['path'] . '/' . $hash . '.' . $mime);
					}
				} catch (Exception $ex) {
					$this->db->rollback();
					throw $ex;
				}
				$this->db->commit();
			} else {
				$hash = md5($file->getContents());
				$file->move('./userfiles/' . $hash);
				$this->db->begin();
				try {
					$nameId = $this->nameModel->setName($file->getName(), 'image');
					$sortKey = $this->db->query("SELECT sort_key FROM image WHERE folder_id=%i ORDER BY sort_key DESC LIMIT 1", $folderId)->fetchSingle();
					$this->db->query("INSERT INTO [image]", array('folder_id' => $folderId, 'name_id' => $nameId, 'hash' => $hash, 'mime' => $mime, 'type' => 'general', 'sort_key' => ++$sortKey));
					$this->uploadedFilesInfo[] = array('id' => $this->db->getInsertId(), 'hash' => $hash);
				} catch(Exception $ex) {
					$this->db->rollback();
					throw $ex;
				}
				$this->db->commit();
			}
		}
		return $this;
	}

	public function getUploadedFilesInfo() {
		return $this->uploadedFilesInfo;
	}

	public function setFolderText($folderId, $text) {
		$this->db->begin();
		try{
			$nameId = $this->nameModel->setName($text, 'folder_has_name', FALSE);
			$this->db->query("INSERT INTO [folder_has_name]", array('folder_id' => $folderId, 'name_id' => $nameId), "ON DUPLICATE KEY UPDATE name_id=%i", $nameId);
		} catch(Exception $ex) {
			$this->db->rollback();
			throw $ex;
		}
		$this->db->commit();
		return $this;
	}

	public function folderExists($menuId) {
		$sql = "SELECT f.id FROM menu_has_folder mhf
			JOIN folder f ON f.id=mhf.folder_id
			WHERE mhf.menu_id=%i AND f.folder_id IS NULL AND f.name_id IS NULL";

		$id = $this->db->query($sql, $menuId)->fetchSingle();
		return !!$id;
	}

	public function remove($id, $type) {
		$this->db->begin();
		try {
			$this->db->query("DELETE FROM %sql WHERE id=%i", $type, $id);
			$this->nameModel->clear($type);
		} catch(Exception $ex) {
			$this->db->rollback();
			throw $ex;
		}
		$this->db->commit();
		return $this;
	}

	public function saveSort($imageId, $oldIndex, $newIndex, $type) {
		$this->db->begin();
		try {
			$folderId = $this->db->query("SELECT folder_id FROM {$type} WHERE id=%i", $imageId)->fetchSingle();
			$rows = $this->db->query("SELECT * FROM {$type} WHERE folder_id=%i ORDER BY sort_key,id", $folderId)->fetchAll();
			foreach($rows as $i => $row) {
				$sortKey = $i+1;
				if($row->sort_key != $sortKey) $this->db->query("UPDATE {$type} SET sort_key=%i WHERE id=%i", $sortKey, $row->id);
			}
			if($newIndex < $oldIndex) {
				$this->db->query("UPDATE {$type} SET sort_key=sort_key+1 WHERE sort_key >= %i AND sort_key < %i AND folder_id=%i", $newIndex, $oldIndex, $folderId);
			} else {
				$this->db->query("UPDATE {$type} SET sort_key=sort_key-1 WHERE sort_key > %i AND sort_key <= %i AND folder_id=%i", $oldIndex, $newIndex, $folderId);
			}
			$this->db->query("UPDATE {$type} SET sort_key=%i WHERE id=%i", $newIndex, $imageId);
		} catch(Exception $ex) {
			$this->db->rollback();
			throw $ex;
		}
		$this->db->commit();
		return $this;
	}

	public function getFoldersByPath($menuId, $path) {
		$folders = $this->getFolders($menuId);
		return $this->search($folders[0], $path);
	}

	private function search($folder, $path) {
		$result = array();
		if(isset($folder['url'])) $part = array_shift($path);
		if(!isset($folder['url']) || $folder['url'] == $part) {
			if(empty($path)) {
				$result = $folder;
			} else {
				foreach($folder['folders'] as $item) {
					$result = $this->search($item, $path);
					if(!empty($result)) break;
				}
			}
		}
		return $result;
	}


	public function loadShare($folderId, $siteId) {
		$sql = "SELECT m.id,text AS name,language_id,l.flag FROM menu m
			JOIN name_has_text nht ON nht.name_id=m.name_id
			JOIN text t ON t.id=nht.text_id
			JOIN language l ON l.id=nht.language_id
			WHERE m.id NOT IN (SELECT menu_id FROM menu_has_folder WHERE folder_id=%i) AND site_id= %i AND type='gallery'";

		return $this->db->fetchAll($sql, $folderId, $siteId);
	}

	public function saveShare($folderId, $menuIds, $menuId) {
		$folders = $this->getFolders($menuId);
		$this->prepareSharedToSave($folders, $folderId);
		$insert = array();
		foreach($this->sharedToSave as $folderId) {
			foreach($menuIds as $menuId) {
				$insert[] = array('folder_id' => $folderId, 'menu_id' => $menuId);
			}
		}
		if(!empty($insert)) $this->db->query("INSERT INTO [menu_has_folder] %ex", $insert);
	}

	protected function prepareSharedToSave($folders, $folderId = null) {
		foreach($folders as $folder) {
			if($folderId == null || $folderId == $folder['id']) {
				$this->sharedToSave[] = $folder['id'];
				if(isset($folder['folders'])) $this->prepareSharedToSave($folder['folders']);
				if($folderId == $folder['id']) break;
			} else {
				if(isset($folder['folders'])) $this->prepareSharedToSave($folder['folders'], $folderId);
			}
		}
	}

	public function getFolderIdFromMenuId($menuId) {
		return $this->db->query("SELECT folder_id FROM menu_has_folder WHERE menu_id=%i", $menuId)->fetchSingle();
	}

}
