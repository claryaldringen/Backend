<?php

class ConfigurationModel{

	/** @var int */
	protected $siteId;

	/** @var int */
	protected $languageId;

	/** @var \Dibi\Connection */
	protected $db;

	/** @var \Dibi\Connection */
	protected $dbPostfix;

	/**
	 * ConfigurationModel constructor.
	 * @param \Dibi\Connection $db
	 * @param \Dibi\Connection $dbPostfix
	 * @param int $siteId
	 * @param int $languageId
	 */
	public function __construct(\Dibi\Connection $db, \Dibi\Connection $dbPostfix, $languageId) {
		$this->db = $db;
		$this->dbPostfix = $dbPostfix;
		$this->languageId = $languageId;
	}

	/**
	 * @param int $siteId
	 * @return $this
	 */
	public function setSiteId($siteId) {
		$this->siteId = $siteId;
		return $this;
	}

	/**
	 * @param int $languageId
	 * @return $this
	 */
	public function setLanguageId($languageId) {
		$this->languageId = $languageId;
		return $this;
	}

	/**
	 * @return int
	 */
	public function getSiteId() {
		return $this->siteId;
	}

	/**
	 * @return int
	 */
	public function getLanguageId() {
		return $this->languageId;
	}

	/**
	 * @return \Dibi\Connection
	 */
	public function getDb() {
		return $this->db;
	}

	/**
	 * @return \Dibi\Connection
	 */
	public function getDbPostfix() {
		return $this->dbPostfix;
	}
}