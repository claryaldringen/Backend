<?php

class ArticleModel extends BaseModel{

	/** @var NameModel */
	protected $nameModel;

	public function __construct(ConfigurationModel $config, NameModel $nameModel) {
		parent::__construct($config);
		$this->nameModel = $nameModel;
	}

	public function getArticles($menuId, $fullArticleId = NULL) {
		$sql = "SELECT a.id,[text] AS html FROM article a
			JOIN name_has_text nht ON a.name_id=nht.name_id AND language_id=%i
			JOIN text t ON t.id=nht.text_id
			WHERE menu_id=%i
			ORDER BY a.id DESC";

		$rows = $this->db->query($sql, $this->getLanguageId(), $menuId)->fetchAll();
		foreach($rows as &$row) {
			if($row['id'] != $fullArticleId) {
				$row['html'] = strip_tags($row['html'], '<h2>');
				$row['html'] = \Nette\Utils\Strings::truncate($row['html'], 1024);
			}
		}
		return $rows;
	}

	public function getArticle($articleId) {
		$sql = "SELECT a.id,[text] AS html FROM article a
			JOIN name_has_text nht ON a.name_id=nht.name_id AND language_id=%i
			JOIN text t ON t.id=nht.text_id
			WHERE a.id=%i";

		return $this->db->query($sql, $this->getLanguageId(), $articleId)->fetch();
	}

	public function setArticle($menuId, $text, $id = NULL) {
		$this->db->begin();
		try {
				$nameId = $this->nameModel->setName($text, 'article', FALSE);
				if($id) {
					$this->db->query("UPDATE [article] SET name_id=%i WHERE id=%i", $nameId, $id);
				} else {
					$this->db->query("INSERT INTO [article] (menu_id, name_id) VALUES (%i, %i)", $menuId, $nameId);
					$id = $this->db->getInsertId();
				}
				$this->nameModel->clear('article');
		}catch (Exception $ex) {
				$this->db->rollback();
				throw $ex;
		}
		$this->db->commit();
		return $id;
	}

	public function removeArticle($articleId) {
		$this->db->query("DELETE FROM article WHERE id=%i", $articleId);
		return $this;
	}

	public function getLength($menuId) {
		$length = $this->db->query("SELECT [length] FROM article_setting WHERE menu_id=?", $menuId)->fetchSingle();
		if(empty($length) && $length !== 0) $length = null;
		return $length;
	}

	public function setLength($menuId, $length = null) {
		$this->db->begin();
		try {
			$this->db->query("DELETE FROM article_setting WHERE menu_id=?", $menuId);
			if ($length !== null) $this->db->query("INSERT INTO article_setting", array('menu_id' => $menuId, 'length' => $length));
		} catch(Exception $ex) {
			$this->db->rollback();
			throw $ex;
		}
		$this->db->commit();
		return $this;
	}
}
