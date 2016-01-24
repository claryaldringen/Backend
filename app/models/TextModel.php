<?php

class TextModel extends BaseModel{

	public function setText($text, $createUrl = true) {
		$url = '';
		if($createUrl) $url = \Nette\Utils\Strings::webalize($text);
		$row = $this->db->query("SELECT [id],[url] FROM [text] WHERE [hash]=CRC32(%s) AND [url]=%s AND [text]=%s", $text, $url, $text)->fetch();
		$textId = $row['id'];
		if(!empty($row) && $row->url != $url) {
			$this->db->query("UPDATE [text] SET url=%s WHERE id=%i", $textId);
		}  elseif(empty($row)) {
			$this->db->query("INSERT INTO [text]", array('text' => $text, 'url' => $url, 'hash' => crc32($text)));
			$textId = $this->db->getInsertId();
		}
		return $textId;
	}

	public function setUrl($textId, $url) {
		$this->db->query("UPDATE [text] SET url=%s WHERE id=%i", $url, $textId);
		return $this;
	}
} 