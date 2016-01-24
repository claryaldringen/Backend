<?php

class NameModel extends BaseModel{

	/** @var  TextModel */
	protected $textModel;

	public function __construct(ConfigurationModel $config, TextModel $textModel) {
		parent::__construct($config);
		$this->textModel = $textModel;
	}

	public function setName($name, $modul, $createUrl = true) {
		$textId = $this->textModel->setText($name, $createUrl);
		$nameId = $this->db->query("SELECT name_id FROM [name_has_text] WHERE text_id=%i AND language_id=%i", $textId, $this->getLanguageId())->fetchSingle();
		if(empty($nameId)) {
			$this->db->query("INSERT INTO [name]", array('modul' => $modul));
			$nameId = $this->db->getInsertId();
			$this->db->query("INSERT INTO [name_has_text]", array('name_id' => $nameId, 'language_id' => $this->getLanguageId(), 'text_id' => $textId));
		}
		return $nameId;
	}

	public function updateName($nameId, $name, $createUrl = true) {
		$textId = $this->textModel->setText($name, $createUrl);
		$insert = array('name_id' => $nameId, 'language_id' => $this->getLanguageId(), 'text_id' => $textId);
		$this->db->query("INSERT INTO [name_has_text] ", $insert, " ON DUPLICATE KEY UPDATE text_id=%i", $textId);
		return $this;
	}

	public function clear($modul, $columns = array('name_id')) {
		$where = array('n.modul=%s');
		$sql = "DELETE n.* FROM [name] n";
		foreach($columns as $i => $column) {
			$sql .= " LEFT JOIN [{$modul}] m{$i} ON n.id=m{$i}.[{$column}] ";
			$where[] = "m{$i}.[$column] IS NULL";
		}
		$sql .= " WHERE " . implode(' AND ', $where);

		try {
			$this->db->query($sql, $modul);
		} catch(DibiDriverException $ex) {
			if($ex->getCode() == 1451) return $this;
			throw $ex;
		}

		$sql = "DELETE t.* FROM [text] t
			LEFT JOIN name_has_text nht ON nht.text_id=t.id
			WHERE nht.name_id IS NULL";

		$this->db->query($sql);
		return $this;
	}

	public function setUrl($nameId, $url) {
		$textId = $this->db->query("SELECT text_id FROM name_has_text WHERE name_id=%i AND language_id=%i", $nameId, $this->getLanguageId())->fetchSingle();
		$this->textModel->setUrl($textId, $url);
		return $this;
	}
}
