<?php
class UserModel extends BaseModel implements \Nette\Security\IAuthenticator
{

	public function authenticate(array $credentials)
	{
		$username = $credentials[self::USERNAME];
		$password = $credentials[self::PASSWORD];

		$sql = "SELECT u.*,a.module_id FROM user u
			JOIN acl a ON a.user_id=u.id AND a.module='site' AND [right] > 0
			WHERE u.login=%s LIMIT 1";

		$row = $this->db->fetch($sql, $username);

		if (!$row) { // uživatel nenalezen?
			throw new \Nette\Security\AuthenticationException("Uživatel '$username' neexistuje.", self::IDENTITY_NOT_FOUND);
		}

		if ($row->password !== md5($password)) { // hesla se neshodují?
			throw new \Nette\Security\AuthenticationException("Špatné heslo.", self::INVALID_CREDENTIAL);
		}

		unset($row['password']);
		return new \Nette\Security\Identity($row->id, NULL, $row); // vrátíme identitu
	}

	public function save($user) {
		if(empty($user['password'])) {
			unset($user['password']);
		} else {
			$user['password'] = md5($user['password']);
		}
		$this->db->query("UPDATE user SET ", $user, " WHERE id=%i", $user['id']);
		return $this;
	}
}
