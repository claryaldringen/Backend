<?php

class EmailModel extends BaseModel
{
	/** @var Dibi\Connection */
	protected $dbPostfix;

	/** @var string */
	protected $domain;

	/** @var int */
	protected $domainId;

	/**
	 * EmailModel constructor.
	 * @param ConfigurationModel $config
	 */
	public function __construct(ConfigurationModel $config)
	{
		$this->db = $config->getDb();
		$this->dbPostfix = $config->getDbPostfix();
		$this->config = $config;
	}

	/**
	 * @return \Dibi\Result|int|string
	 */
	public function getDomain() {
		if(empty($this->domain)) {
			$this->domain = $this->db->query("SELECT site FROM site WHERE id=%i", $this->config->getSiteId())->fetchSingle();
		}
		return $this->domain;
	}

	public function getDomainId() {
		if(empty($this->domainId)) {
			$this->domainId = $this->dbPostfix->query("SELECT id FROM domain WHERE name=%s", $this->getDomain());
		}
		return $this->domainId;
	}

	/**
	 * @return \Dibi\Row[]
	 */
	public function getEmails() {
		$sql = "SELECT m.id,m.user AS username,password,a.target AS alias FROM mailbox m
			JOIN domain d ON m.domain_id=d.id
			LEFT JOIN alias a ON a.domain_id=d.id AND a.user=m.user
			WHERE d.name=%s";

		return $this->dbPostfix->query($sql, $this->getDomain())->fetchAll();
	}

	/**
	 * @param array $emails
	 * @return $this
	 * @throws Exception
	 * @throws \Dibi\Exception
	 */
	public function setEmails(array $emails) {
		$this->dbPostfix->begin();
		try {
			foreach ($emails as $email) {
				if (!empty($email->id)) {
					$this->dbPostfix->query("UPDATE mailbox SET [user]=%s, password=%s WHERE id=%i", $email->username, $email->password, $email->id);
				} else {
					$this->dbPostfix->query("INSERT INTO mailbox", array('user' => $email->username, 'password' => $email->password, 'domain_id' => $this->getDomainId()));
				}

				if (!empty($email->alias)) {
					$aliases = explode(',', str_replace(' ', '', $email->alias));
					foreach ($aliases as $alias) {
						if (!\Nette\Utils\Validators::isEmail($alias)) throw new CmsException($alias . ' není platný email.');
					}
					$aliasId = $this->dbPostfix->query("SELECT id FROM alias WHERE domain_id=%i AND [user]=%s", $this->getDomainId(), $email->username)->fetchSingle();
					if (!empty($aliasId)) {
						$this->dbPostfix->query("UPDATE alias SET target=%s WHERE id=%i", implode(',', $aliases), $aliasId);
					} else {
						$this->dbPostfix->query("INSERT INTO alias", array('domain_id' => $this->getDomainId(), 'user' => $email->username, 'target' => implode(',', $aliases)));
					}
				}
			}
		} catch(Exception $ex) {
			$this->dbPostfix->rollback();
			throw $ex;
		}
		$this->dbPostfix->commit();
		return $this;
	}

	public function removeEmail($id) {
		$this->dbPostfix->query("DELETE FROM mailbox WHERE id=%i", $id);
		return $this;
	}
}