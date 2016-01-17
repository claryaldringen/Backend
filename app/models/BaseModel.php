<?php

use Nette;

class BaseModel extends Nette\Object{

	/** @var DibiConnection */
	protected $db;

	protected $languageId = 1;

	/** @var  ConfigurationModel */
	protected $config;

	public function __construct(ConfigurationModel $config)
	{
		$this->db = $config->getDb();
		$this->config = $config;
	}

	public function getLanguageId() {
		return $this->config->getLanguageId();
	}

}