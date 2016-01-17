<?php
/**
 * Created by PhpStorm.
 * User: clary
 * Date: 26.12.14
 * Time: 14:06
 */

class PageModel extends BaseModel{

	/** @var NameModel */
	protected $nameModel;

	public function __construct(ConfigurationModel $config, NameModel $nameModel) {
		parent::__construct($config);
		$this->nameModel = $nameModel;
	}

	public function  getPage($menuId) {
		$sql = "SELECT [text] FROM [page] p
			JOIN [name_has_text] nht ON p.name_id=nht.name_id AND language_id=%i
			JOIN [text] t ON t.id=nht.text_id
			WHERE menu_id=%i";

		return $this->db->query($sql, $this->getLanguageId(), $menuId)->fetchSingle();
	}

	public function setPage($menuId, $text) {
		$this->db->begin();
		try {
			$nameId = $this->nameModel->setName($text, 'page', FALSE);
			$this->db->query("INSERT INTO [page] (menu_id, name_id) VALUES (%i, %i) ON DUPLICATE KEY UPDATE name_id=%i", $menuId, $nameId, $nameId);
			$this->nameModel->clear('page');
		}catch (Exception $ex) {
			$this->db->rollback();
			throw $ex;
		}
		$this->db->commit();
		return $this;
	}
}