<?php


$container = require __DIR__ . '/../app/bootstrap.php';

/** @var Dibi\Connection $db */
$db = $container->getService('db');
//$manager = $container->getByType('App\Model\UserManager');

$messages = ['site' => 'Site name: ', 'name' => 'User name: ', 'login' => 'User login: ', 'password' => 'Password: '];

$data = [];
foreach($messages as $var => $message) {
	$data[$var] = readline($message);
}

$db->begin();
try {
	$db->query("INSERT INTO site", ['site' => $data['site']]);
	$siteId = $db->getInsertId();
	$db->query("INSERT INTO [user]", ['name' => $data['name'], 'login' => $data['login'], 'password' => md5($data['password'])]);
	$userId = $db->getInsertId();
	$db->query("INSERT INTO acl", ['module' => 'site', 'module_id' => $siteId, 'user_id' => $userId, 'right' => 2]);
	$db->query("INSERT INTO menu", ['site_id' => $siteId, 'type_id' => 2, 'visibility' => 'invisible']);
	$menuId = $db->getInsertId();
	$db->query("INSERT INTO folder", ['sort_key' => 0]);
	$folderId = $db->getInsertId();
	$db->query("INSERT INTO menu_has_folder", ['menu_id' => $menuId, 'folder_id' => $folderId]);
} catch(Exception $ex) {
	$db->rollback();
	throw $ex;
}
$db->commit();

echo "Done.\n";
