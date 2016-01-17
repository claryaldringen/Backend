<?php
/**
 * Created by PhpStorm.
 * User: clary
 * Date: 20.2.15
 * Time: 6:09
 */

class LanguageModel extends BaseModel{

	public function load() {
		return $this->db->query("SELECT id,name FROM [language]")->fetchAll();
	}
}