<?php



/**
 * Router factory.
 */
class RouterFactory
{

	/**
	 * @return \Nette\Application\IRouter
	 */
	public function createRouter()
	{
		$router = new \Nette\Application\Routers\RouteList();

		$router[] = new \Nette\Application\Routers\Route('/image-browser.html',array(
			'presenter' => 'Admin',
			'action' => 'imageBrowser'
		));

		$router[] = new \Nette\Application\Routers\Route('/file-browser.html',array(
			'presenter' => 'Admin',
			'action' => 'fileBrowser'
		));

		$router[] = new \Nette\Application\Routers\Route('/site/<siteId>',array(
			'presenter' => 'Admin',
			'action' => 'setSite',
		));

		$router[] = new \Nette\Application\Routers\Route('/login.html',array(
				'presenter' => 'Admin',
				'action' => 'login'
		));

		$router[] = new \Nette\Application\Routers\Route('/ajax/',array(
			'presenter' => 'Ajax',
			'action' => 'default',
		));

		$router[] = new \Nette\Application\Routers\Route('',array(
			'presenter' => 'Admin',
			'action' => 'default',
		));

		return $router;
	}

}
