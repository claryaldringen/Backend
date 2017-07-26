<?php
/**
 * Created by PhpStorm.
 * User: clary
 * Date: 26.12.14
 * Time: 12:50
 */

class AjaxPresenter extends \Nette\Application\UI\Presenter{

	public function renderDefault() {
		// \Tracy\Debugger::enable(\Tracy\Debugger::PRODUCTION);
		$session = $this->getSession('cms');
		$this->context->getService('configurationModel')->setLanguageId($session->languageId)->setSiteId($session->siteId);
		$post = $this->request->post;
		try {
			$this->template->response = $this->{$post['action']}(json_decode($post['data']));
		} catch(Exception $ex) {
			if ($ex instanceof CmsException) {
				$this->template->response = array('errorCode' => 2,'error' => $ex->getMessage());
			} else {
				$this->template->response = array('errorCode' => 1, 'error' => $ex->getMessage() . 'on line ' . $ex->getLine() . ' at ' . $ex->getFile() . "\n\n" . $ex->getTraceAsString());
				\Tracy\Debugger::log($ex);
			}
		}
	}

	protected function loadMenu($data) {
		$tree = $this->context->getService('menuModel')->getMenu($data->type);
		if($data->type == 'visible') {
			return array('items' => $tree[0]['items']);
		} else {
			return array('items' => $tree);
		}
	}

	protected function saveMenu($data) {
		$tree = $this->context->getService('menuModel')->setMenu($data)->getMenu();
		return array('items' => $tree[0]['items']);
	}

	protected function saveFloat($data) {
		$items = $this->context->getService('menuModel')->setMenu($data)->getMenu('invisible');
		return array('items' => $items);
	}

	protected function  loadPage($data) {
		$text = $this->context->getService('pageModel')->getPage($data->pageId);
		if(empty($text)) $text = '';
		return array('text' => $text);
	}

	protected function savePage($data) {
		if($data->typeId == 1) {
			$this->context->getService('pageModel')->setPage($data->pageId, $data->text);
		} else {
			$this->context->getService('galleryModel')->setFolderText($data->folderId, $data->text);
		}
		return array('text' => $data->text);
	}

	protected function loadGallery($data) {
		return $this->context->getService('galleryModel')->getFolders($data->menuId, $data->showType);
	}

	protected function createGalleryFolder($data) {
		return $this->context->getService('galleryModel')->createFolder($data->parent, $data->menuId)->getFolders($data->menuId);
	}

	protected function renameGalleryItem($data) {
		$model = $this->context->getService('galleryModel');
		if($data->type == 'folder') {
			$model->setFolderName($data->id, $data->name);
		} else {
			$model->setImageName($data->id, $data->name);
		}
		return $model->getFolders($data->menuId);
	}

	protected function saveImage($data) {
		$this->context->getService('galleryModel')->saveImages($this->request->getFiles(), $data->folderId);
	}

	protected function deleteGalleryItem($data) {
		return $this->context->getService('galleryModel')->remove($data->id, $data->type)->getFolders($data->menuId);
	}

	protected function saveContentType($data) {
		$this->context->getService('menuModel')->setType($data->menuId, $data->newTypeId);
		$model = $this->context->getService('galleryModel');
		if($data->newTypeId == 2 && !$model->folderExists($data->menuId)) {
			$model->createFolder(NULL, $data->menuId, NULL);
		}
	}

	protected function logout() {
		$this->user->logout(TRUE);
		return $this->link('Admin:login');
	}

	protected function loadUser() {
		return $this->user->identity->data;
	}

	protected function saveUser($data) {
		$user = array(
			'id' => $this->user->id,
			'name' => $data->name,
			'login' => $data->login,
			'email' => $data->email,
			'password' => @$data->password1
		);
		$this->context->getService('userModel')->save($user);
	}

	protected function saveSort($data) {
		return $this->context->getService('galleryModel')->saveSort($data->id, $data->oldIndex, $data->newIndex, $data->type)->getFolders($data->menuId);
	}

	protected function loadLanguages($data) {
		return array('languages' => $this->context->getService('languageModel')->load(), 'selected' => $this->context->getService('configurationModel')->getLanguageId());
	}

	protected function useLanguage($data) {
		$session = $this->getSession('cms');
		$session->languageId = $data->languageId;
	}

	protected function loadShare($data) {
		return array('items' => $this->context->getService('galleryModel')->loadShare($data->folderId, $this->context->getService('configurationModel')->getSiteId()));
	}

	protected function saveShare($data) {
		$this->context->getService('galleryModel')->saveShare($data->folderId, $data->menuIds, $data->menuId);
	}

	protected function ping($data) {
		return $this->user->isLoggedIn();
	}

	protected function loadArticles($data) {
		$model = $this->context->getService('articleModel');
		return array('articles' => $model->getArticles($data->menuId), 'length' => $model->getLength($data->menuId), 'count' => $model->getCount($data->menuId));
	}

	protected function loadArticle($data) {
		return $this->context->getService('articleModel')->getArticle($data->articleId);
	}

	protected function saveArticle($data) {
		$model = $this->context->getService('articleModel');
		$id = $model->setArticle($data->menuId, $data->text, $data->articleId);
		return array('articles' => $model->getArticles($data->menuId, $id), 'length' => $model->getLength($data->menuId), 'count' => $model->getCount($data->menuId));
	}

	protected function removeArticle($data) {
		$model = $this->context->getService('articleModel');
		$model->removeArticle($data->articleId);
		return array('articles' => $model->getArticles($data->menuId), 'length' => $model->getLength($data->menuId), 'count' => $model->getCount($data->menuId));
	}

	protected function loadTypes() {
		return $this->context->getService('typeModel')->getTypes();
	}

	protected function saveAudio($data) {
		$this->context->getService('galleryModel')->saveImages($this->request->getFiles(), $this->context->getService('galleryModel')->getFolderIdFromMenuId($this->context->getService('menuModel')->getIdOfGeneralGallery()));
		$info = $this->context->getService('galleryModel')->getUploadedFilesInfo();
		return array('fileId' => $info[0]['id'], 'hash' => $info[0]['hash'], 'album' => $data->album, 'song' => $data->song);
	}

	protected function saveAlbumImage($data) {
		$this->context->getService('galleryModel')->saveImages($this->request->getFiles(), $this->context->getService('galleryModel')->getFolderIdFromMenuId($this->context->getService('menuModel')->getIdOfGeneralGallery()));
		$info = $this->context->getService('galleryModel')->getUploadedFilesInfo();
		return array('fileId' => $info[0]['id'], 'hash' => $info[0]['hash'], 'album' => $data->album);
	}

	protected function saveAlbum($data) {
		$id = $this->context->getService('discographyModel')->saveAlbum($data->album, $data->menuId);
		$albums = $this->context->getService('discographyModel')->getDiscography($data->menuId, $id);
		return array('index' => $data->albumIndex, 'album' => $albums[0]);
	}

	protected function removeAlbum($data) {
		$this->context->getService('discographyModel')->removeAlbum($data->albumId);
		return array('index' => $data->albumIndex);
	}

	protected function loadDiscography($data) {
		return $this->context->getService('discographyModel')->getDiscography($data->menuId);
	}

	protected function loadComments($data) {
		return array('comments' => $this->context->getService('commentModel')->getComments($data->menuId));
	}

	protected function saveComment($data) {
		$comments = $this->context->getService('commentModel')->setComment($data)->getComments($data->menu_id);
		return array('comments' => $comments);
	}

	protected function removeComment($data) {
		$comments = $this->context->getService('commentModel')->removeComment($data->id)->getComments($data->menuId);
		return array('comments' => $comments);
	}

	protected function addContainer($data) {
		$id = $this->context->getService('menuModel')->addContainer($data->menuId);
		return array('id' => $id);
	}

	protected function loadContainers($data) {
		$containers = $this->context->getService('menuModel')->getContainers($data->menuId);
		return array('containers' => $containers);
	}

	protected function removeContainer($data) {
		$containers = $this->context->getService('menuModel')->removeContainer($data->containerId)->getContainers($data->menuId);
		return array('containers' => $containers);
	}

	protected function loadConcerts($data) {
		$concerts = $this->context->getService('concertModel')->getConcerts($data->menuId);
		return array('concerts' => $concerts);
	}

	protected function saveConcertImage($data) {
		$this->context->getService('galleryModel')->saveImages($this->request->getFiles(), $this->context->getService('galleryModel')->getFolderIdFromMenuId($this->context->getService('menuModel')->getIdOfGeneralGallery()));
		$info = $this->context->getService('galleryModel')->getUploadedFilesInfo();
		return array('fileId' => $info[0]['id'], 'hash' => $info[0]['hash']);
	}

	protected function saveConcert($data) {
		$this->context->getService('concertModel')->saveConcert($data);
		$concerts = $this->context->getService('concertModel')->getConcerts($data->menu_id);
		return array('concerts' => $concerts);
	}

	protected function removeConcert($data) {
		$concerts = $this->context->getService('concertModel')->removeConcert($data->id)->getConcerts($data->menuId);
		return array('concerts' => $concerts);
	}

	protected function saveArticleSetting($data) {
		$this->context->getService('articleModel')->setSetting($data->menuId, $data->length, $data->count);
	}

	protected function moveArticle($data) {
		$model = $this->context->getService('articleModel');
		$model->moveArticle($data->articleId, $data->menuId, $data->order);
		return array('articles' => $model->getArticles($data->menuId), 'length' => $model->getLength($data->menuId), 'count' => $model->getCount($data->menuId));
	}

	protected function loadEmails() {
		$model = $this->context->getService('emailModel');
		$domain = $model->getDomain();
		$emails = $model->getEmails();
		return array('domain' => $domain, 'emails' => $emails);
	}

	protected function saveEmails($data) {
		$this->context->getService('emailModel')->setEmails($data);
		return $this->loadEmails();
	}

	protected function removeEmail($data) {
		$this->context->getService('emailModel')->removeEmail($data->id);
		return $this->loadEmails();
	}

	protected function loadSites() {
		return $this->context->getService("siteModel")->getSites();
	}

	protected function setSite($data) {
		$this->getSession('cms')->siteId = $data->id;
		$this->context->getService('configurationModel')->setSiteId($data->id);
		return true;
	}

	protected function loadArticleCategories() {
		return $this->context->getService('menuModel')->getMenuItemsByType(3);
	}

	protected function setArticleCategory($data) {
		$model = $this->context->getService('articleModel');
		$model->setArticleCategory($data->articleId, $data->newMenuId);
		return array('articles' => $model->getArticles($data->menuId), 'length' => $model->getLength($data->menuId), 'count' => $model->getCount($data->menuId));
	}
}
