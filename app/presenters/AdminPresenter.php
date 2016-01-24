<?php

class AdminPresenter extends \Nette\Application\UI\Presenter{

	public function createComponentLoginForm()
	{
		$form = new \Nette\Application\UI\Form($this,'loginForm');
		$form->addText('login','Uživatelské jméno:')->addRule(\Nette\Application\UI\Form::FILLED,'Musíte vyplnit uživatelské jméno!');
		$form->addPassword('password','Heslo:')->addRule(\Nette\Application\UI\Form::FILLED,'Musíte vyplnit heslo!');
		$form->addSubmit('doLogin','Přihlásit se');
		$form->onSuccess[] = array($this,'loginFormSubmitted');
		return $form;
	}

	public function loginFormSubmitted(\Nette\Application\UI\Form $NForm)
	{
		try{
			$user = $this->getUser();
			$user->login($NForm['login']->getValue(),$NForm['password']->getValue());
			$this->getSession('cms')->siteId = $user->getIdentity()->data['module_id'];
			$this->redirect('default');
		}catch(\Nette\Security\AuthenticationException $ex){
			$this->flashMessage($ex->getMessage(),'err');
		}
	}

	public function actionDefault() {
		if(!$this->getUser()->isLoggedIn()) $this->redirect('login');
		$session = $this->getSession('cms');
		if(!isset($session->languageId)) $session->languageId = $this->context->getService('configurationModel')->getLanguageId();
	}

	public function actionSetSite($siteId) {
		$session = $this->getSession('cms');
		if($session->siteId != $siteId) {
			$session->siteId = $siteId;
			$this->user->logout(true);
		}
		$this->redirect('default');
	}

	public function actionImageBrowser() {
		$this->context->getService('menuModel')->setSiteId($this->getSession('cms')->siteId);
		$this->template->generallGalleryId = $this->context->getService('menuModel')->getIdOfGeneralGallery();
	}

	public function actionFileBrowser() {
		$this->context->getService('menuModel')->setSiteId($this->getSession('cms')->siteId);
		$this->template->generallGalleryId = $this->context->getService('menuModel')->getIdOfGeneralGallery();
	}

	public function renderDefault() {
		$this->template->title = $this->context->getService('siteModel')->getSiteName($this->getSession('cms')->siteId);
	}

	public function renderLogin() {
		$this->template->title = $this->context->getService('siteModel')->getSiteName($this->getSession('cms')->siteId);
	}
}
