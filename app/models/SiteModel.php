<?php

class SiteModel extends BaseModel {

	public function getSiteName($id) {
		return $this->db->query("SELECT site FROM site WHERE id=%i", $id)->fetchSingle();
	}

	public function getSiteId($name) {
		return $this->db->query("SELECT id FROM site WHERE site=%s", $name)->fetchSingle();
	}
}
