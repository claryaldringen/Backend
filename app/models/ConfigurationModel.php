<?php
/**
 * Created by PhpStorm.
 * User: clary
 * Date: 20.2.15
 * Time: 7:02
 */

class ConfigurationModel{

	protected $siteId;

	protected $languageId;

	public function __construct(DibiConnection $db, $siteId, $languageId) {
		$this->db = $db;
		$this->siteId = $siteId;
		$this->languageId = $languageId;
	}

	public function setLanguageId($languageId) {
		$this->languageId = $languageId;
		return $this;
	}

	public function getSiteId() {
		return $this->siteId;
	}

	public function getLanguageId() {
		return $this->languageId;
	}

	public function getDb() {
		return $this->db;
	}
}