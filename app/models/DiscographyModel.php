<?php

class DiscographyModel extends BaseModel
{
	/** @var NameModel */
	protected $nameModel;

	public function __construct(ConfigurationModel $config, NameModel $nameModel) {
		parent::__construct($config);
		$this->nameModel = $nameModel;
	}

	public function saveAlbum($album, $menuId) {
		$this->db->begin();
		try {
			if(isset($album->name) && $album->name) {
				$nameId = $this->nameModel->setName($album->name, 'album', TRUE);
				if($album->text == null) $album->text = '';
				$textNameId = $this->nameModel->setName($album->text, 'album', FALSE);
				if(!isset($album->imageId)) $album->imageId = NULL;
				if(!isset($album->year)) $album->year = date('Y');
				if (isset($album->id) && $album->id) {
					$this->db->query("UPDATE [album] SET name_id=%i,image_id=%i,[year]=%i,text_name_id=%i,link=%s,price=%i,[count]=%i WHERE id=%i", $nameId, $album->imageId, $album->year,$textNameId, $album->link, $album->price, $album->count, $album->id);
					$id = $album->id;
				} else {
					$insert = array(
						'menu_id' => $menuId,
						'name_id' => $nameId,
						'text_name_id' => $textNameId,
						'image_id' => $album->imageId,
						'year' => $album->year,
						'link' => $album->link,
						'price' => $album->price,
						'count' => $album->count
					);
					$this->db->query("INSERT INTO [album] ", $insert);
					$id = $this->db->getInsertId();
				}
			}
			foreach($album->songs as $song) {
				if(!empty($song->name) || !empty($song->text) || !empty($song->fileId)) {
					$nameId = $this->nameModel->setName($song->name, 'song', FALSE);
					$textNameId = $this->nameModel->setName($song->text, 'song', FALSE);
					$fileId = isset($song->fileId) ? $song->fileId : null;
					$link = isset($song->link) ? $song->link : null;
					if (isset($song->id) && $song->id) {
						$this->db->query("UPDATE [song] SET name_id=%i, image_id=%i, text_name_id=%i,sort_key=%i,link=%s WHERE id=%i", $nameId, $fileId, $textNameId, $song->sortKey, $link, $song->id);
					} else {
						$insert = array(
							'name_id' => $nameId,
							'text_name_id' => $textNameId,
							'image_id' => $fileId,
							'album_id' => $id,
							'link' => $album->link,
							'sort_key' => $song->sortKey
						);
						$this->db->query("INSERT INTO [song] ", $insert);
					}
				} else if(empty($song->name) && !empty($song->id)) {
					$this->db->query("DELETE FROM song WHERE id=%i", $song->id);
					$this->nameModel->clear('song', array('name_id', 'text_name_id'));
				}
			}
		}catch (Exception $ex) {
			$this->db->rollback();
			throw $ex;
		}
		$this->db->commit();
		return $id;
	}

	public function getDiscography($menuId, $albumId = null) {
		$sql = "SELECT a.id,a.year,t.text AS name,i.id AS imageId,i.hash AS image,t2.text,a.link,a.price,a.count FROM album a
			LEFT JOIN image i ON i.id=a.image_id
			JOIN name_has_text nht ON nht.name_id=a.name_id AND nht.language_id=%i
			JOIN text t ON t.id=nht.text_id
			LEFT JOIN name_has_text nht2 ON nht2.name_id=a.text_name_id AND nht2.language_id=%i
			LEFT JOIN text t2 ON t2.id=nht2.text_id
			WHERE menu_id=%i " . (empty($albumId) ? '' : " AND a.id={$albumId}") . "
			ORDER BY [year] DESC,id DESC, updated DESC ";

		$ids = array();
		$albums = $this->db->query($sql, $this->getLanguageId(), $this->getLanguageId(), $menuId)->fetchAll();
		foreach($albums as &$row) {
			$ids[] = $row->id;
			$row->songs = array();
		}

		$sql = "SELECT s.id,t1.text AS name,t2.text,i.id AS fileId,i.hash AS file,s.album_id,s.sort_key AS sortKey,s.link FROM song s
			LEFT JOIN image i ON i.id=s.image_id
			JOIN name_has_text nht1 ON nht1.name_id=s.name_id AND nht1.language_id=%i
			JOIN text t1 ON t1.id=nht1.text_id
			LEFT JOIN name_has_text nht2 ON nht2.name_id=s.text_name_id AND nht2.language_id=%i
			LEFT JOIN text t2 ON t2.id=nht2.text_id
			WHERE s.album_id IN %in";

		$songs = $this->db->query($sql, $this->getLanguageId(), $this->getLanguageId(), $ids)->fetchAll();
		foreach($albums as &$row) {
			foreach ($songs as $song) {
				if ($song->album_id == $row->id) $row->songs[] = $song;
			}
		}
		return $albums;
	}

	public function removeAlbum($id) {
		$this->db->begin();
		try {
			$this->db->query("DELETE FROM song WHERE album_id=%i", $id);
			$this->db->query("DELETE FROM album WHERE id=%i", $id);
			$this->nameModel
				->clear('album', array('name_id', 'text_name_id'))
				->clear('song', array('name_id', 'text_name_id'));
		} catch(Exception $ex) {
			$this->db->rollback();
			throw $ex;
		}
		$this->db->commit();
	}
}