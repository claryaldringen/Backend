<?php

class ArticleModel extends BaseModel{

	/** @var NameModel */
	protected $nameModel;

	protected $data = array();

	public function __construct(ConfigurationModel $config, NameModel $nameModel) {
		parent::__construct($config);
		$this->nameModel = $nameModel;
	}

	public function getArticles($menuId, $fullArticleId = NULL) {
		$sql = "SELECT a.id,[text] AS html FROM article a
			JOIN name_has_text nht ON a.name_id=nht.name_id AND language_id=%i
			JOIN text t ON t.id=nht.text_id
			WHERE menu_id=%i
			ORDER BY a.sort ASC,a.id DESC";

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
			$this->setArticleUrl($text, $menuId, $id, $nameId);
			$this->moveArticleUp($menuId);
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
		$length = $this->loadSetting($menuId)->data[$menuId]['length'];
		if(empty($length) && $length !== 0) $length = null;
		return $length;
	}

	public function getCount($menuId) {
		return $this->loadSetting($menuId)->data[$menuId]['count'];
	}

	private function loadSetting($menuId) {
		if(empty($this->data[$menuId])) {
			$row = $this->db->query("SELECT * FROM article_setting WHERE menu_id=?", $menuId)->fetch();
			$this->data[$menuId] = array('length' => $row->length, 'count' => $row->count);
		}
		return $this;
	}

	public function setSetting($menuId, $length = null, $count = 8) {
		$this->db->begin();
		try {
			$this->db->query("DELETE FROM article_setting WHERE menu_id=?", $menuId);
			if ($length !== null) $this->db->query("INSERT INTO article_setting", array('menu_id' => $menuId, 'length' => $length, 'count' => $count));
		} catch(Exception $ex) {
			$this->db->rollback();
			throw $ex;
		}
		$this->db->commit();
		return $this;
	}

	public function moveArticle($articleId, $menuId, $order) {
		$rows = $this->db->query("SELECT id,sort FROM article WHERE menu_id=%i ORDER BY sort ASC,id DESC", $menuId)->fetchAll();
		foreach($rows as $sort => $row) {
			$current = $sort;
			if($articleId == $row->id) {
				if($order == 'down') {
					$sort++;
				} else {
					$sort--;
				}
				$this->db->query("UPDATE article SET sort=%i WHERE id=%i", $current, $rows[$sort]->id);
			}
			if($row->sort != $sort) $this->db->query("UPDATE article SET sort=%i WHERE id=%i", $sort, $row->id);
		}
		return $this;
	}

	protected function setArticleUrl($text, $menuId, $articleId, $nameId) {
		for($number = 1; $number < 7; $number++) {
			$start = strpos($text, '<h' . $number . '>');
			$end = strpos($text, '</h' . $number . '>');
			if($start !== false && $end !== false) {
				$caption = \Nette\Utils\Strings::webalize(html_entity_decode(substr($text, $start + 4, $end - ($start + 4))));
				if(!$this->checkCaption($menuId, $caption, $articleId)) $caption .= '-' . $articleId;
				$this->nameModel->setUrl($nameId, $caption);
				return $this;
			}
		}
		throw new CmsException('Článek nemá žádný nadpis. Doplňte prosím chybějící nadpis a uložte článek znovu.');
	}

	private function checkCaption($menuId, $url, $articleId) {
		$sql = "SELECT a.id FROM article a
			JOIN name_has_text nht ON nht.name_id=a.name_id AND nht.language_id=%i
			JOIN text t ON t.id=nht.text_id
			WHERE a.menu_id=%i AND url=%s AND a.id != %i";

		$row = $this->db->query($sql, $this->getLanguageId(), $menuId, $url, $articleId)->fetchSingle();
		return empty($row);
	}

	private function moveArticleUp($menuId) {
		$this->db->query("UPDATE article SET sort = sort + 1 WHERE menu_id=%i", $menuId);
		return $this;
	}

}
