<?php

class SiteModel extends BaseModel {

	public function getSiteName($id) {
		return $this->db->query("SELECT site FROM site WHERE id=%i", $id)->fetchSingle();
	}
}