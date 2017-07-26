<?php
/**
 * Created by PhpStorm.
 * User: clary
 * Date: 15.11.14
 * Time: 16:16
 */

class MenuModel extends BaseModel{

	/** @var NameModel */
	protected $nameModel;

	/** @var Library */
	protected $library;

	protected $menu = array();

	protected $siteId;

	public function __construct(ConfigurationModel $config, NameModel $nameModel, Library $library) {
		parent::__construct($config);
		$this->nameModel = $nameModel;
		$this->library = $library;
	}

	public function getMenu($type = 'visible') {
		if(!isset($this->menu[$type])) {
			$sql = "SELECT m.id,m.menu_id,m.type_id AS type,t.text,t.url,m.visibility FROM [menu] m
			JOIN [name_has_text] nht ON m.name_id=nht.name_id AND language_id=%i
			JOIN [text] t ON t.id=nht.text_id
			WHERE site_id=%i AND m.visibility = %s
			ORDER BY [sort],[id]";

			$rows = $this->db->query($sql, $this->getLanguageId(), $this->config->getSiteId(), $type)->fetchAll();
			foreach($rows as &$row) $row['menu_id'] = (int)$row['menu_id'];
			if($type == 'visible') {
				array_unshift($rows, new DibiRow(array('id' => 0, 'menu_id' => null)));
				$tree = $this->library->convertToTree($rows, 'id', 'menu_id', 'items');
				$tree[0]['items'] = $this->library->removeKeys($tree[0]['items'], 'items');
				$this->menu[$type] = $tree;
			} else {
				$this->menu[$type] = $rows;
			}
		}
		return $this->menu[$type];
	}

	public function setMenu(array $items) {
		$this->db->begin();
		try {
			$this->saveMenu($items, 0);
			$this->nameModel->clear('menu');
		} catch(Exception $ex) {
			$this->db->rollback();
			throw $ex;
		}
		$this->db->commit();
		return $this;
	}

	protected function saveMenu(array $items, $parentId) {
		foreach ($items as $sort => $item) {
			if(!empty($item->text)) {
				$nameId = $this->nameModel->setName($item->text, 'menu');
				if(isset($item->id)) {
					$this->db->query("UPDATE [menu] SET name_id=%i,sort=%i WHERE id=%i", $nameId, $sort, $item->id);
				} else {
					$this->db->query("INSERT INTO [menu]", array('menu_id' => $parentId, 'name_id' => $nameId, 'site_id' => $this->config->getSiteId(), 'sort' => $sort, 'visibility' => $item->visibility));
				}
			} elseif(isset($item->id)) {
				$this->db->query("DELETE FROM [menu] WHERE id=%i", $item->id);
			}
			if(isset($item->items)) $this->saveMenu($item->items, $item->id);
		}
	}

	public function setType($menuId, $typeId) {
		$this->db->query("UPDATE [menu] SET type_id=%i WHERE id=%i", $typeId, $menuId);
		return $this;
	}

	public function getIdOfGeneralGallery() {
		return $this->db->query("SELECT id FROM menu WHERE visibility='invisible' AND name_id IS NULL AND site_id=%i", $this->config->getSiteId())->fetchSingle();
	}

	public function addContainer($menuId) {
		$this->db->query("INSERT INTO menu", array('site_id' => $this->config->getSiteId(), 'menu_id' => $menuId, 'visibility' => 'invisible'));
		return $this->db->getInsertId();
	}

	public function getContainers($menuId) {
		return $this->db->query("SELECT id,type_id FROM menu WHERE menu_id=%i AND visibility='invisible'", $menuId)->fetchAll();
	}

	public function removeContainer($id) {
		$this->db->query("DELETE FROM menu WHERE id=%i", $id);
		return $this;
	}

	public function getMenuItemsByType($typeId) {
		$sql = "SELECT m.id,text FROM menu m
			JOIN name_has_text nht ON nht.name_id=m.name_id AND language_id=?
			JOIN text t ON t.id=nht.text_id
			WHERE site_id=? AND m.type_id=?";

		return $this->db->query($sql, $this->getLanguageId(), $this->config->getSiteId(), $typeId)->fetchPairs();
	}

}
