<?php

class TypeModel extends BaseModel{

	public function getTypes() {
	  return $this->db->query("SELECT * FROM [type]")->fetchAll();
	}
}