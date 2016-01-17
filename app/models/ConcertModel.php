<?php

class ConcertModel extends BaseModel {

	/** @var NameModel */
	protected $nameModel;

	public function __construct(ConfigurationModel $config, NameModel $nameModel)
	{
		parent::__construct($config);
		$this->nameModel = $nameModel;
	}

	public function getConcerts($menuId) {

		$languageId = $this->getLanguageId();

		$sql = "SELECT c.id,c.menu_id,c.start_time,c.ticket_uri,t1.text AS name,t2.text AS place,t3.text,i.hash AS image,i.id AS image_id FROM concert c
			JOIN name_has_text nht1 ON nht1.name_id=c.name_id AND nht1.language_id=%i
			JOIN text t1 ON t1.id=nht1.text_id
			JOIN name_has_text nht2 ON nht2.name_id=c.place_name_id AND nht2.language_id=%i
			JOIN text t2 ON t2.id=nht2.text_id
			JOIN name_has_text nht3 ON nht3.name_id=c.text_name_id AND nht3.language_id=%i
			JOIN text t3 ON t3.id=nht3.text_id
			LEFT JOIN image i ON i.id=c.image_id
			WHERE menu_id=%i ORDER BY start_time DESC";

		$rows = $this->db->query($sql, $languageId, $languageId, $languageId, $menuId)->fetchAll();
		foreach($rows as &$row) {
			$row['start_time'] = date('Y-m-d\TH:i', strtotime($row['start_time']));
		}

		return $rows;
	}

	public function saveConcert($data) {
		$this->db->begin();
		try {
			$nameId = $this->nameModel->setName($data->name, 'concert', FALSE);
			$placeId = $this->nameModel->setName($data->place, 'concert', FALSE);
			$textId = $this->nameModel->setName($data->text, 'concert', FALSE);
			if ($data->id) {
				$id = $data->id;
				$sql = "UPDATE concert SET name_id=%i,text_name_id=%i,place_name_id=%i,image_id=%i,start_time=%s,ticket_uri=%s WHERE id=%i";
				$this->db->query($sql, $nameId, $textId, $placeId, $data->image_id, date('Y-m-d H:i:s', strtotime($data->start_time)), $data->ticket_uri, $id);
			} else {
				$insert = array(
					'name_id' => $nameId,
					'menu_id' => $data->menu_id,
					'place_name_id' => $placeId,
					'text_name_id' => $textId,
					'image_id' => $data->image_id,
					'start_time' => $data->start_time,
					'ticket_uri' => $data->ticket_uri
				);
				$this->db->query("INSERT INTO concert", $insert);
				$id = $this->db->getInsertId();
			}
			$this->nameModel->clear('concert', array('name_id', 'place_name_id', 'text_name_id'));
			$this->db->commit();
		} catch(Exception $ex) {
			$this->db->rollback();
			throw $ex;
		}
		return $id;
	}

	public function removeConcert($id) {
		$this->db->begin();
		try {
			$this->db->query("DELETE FROM concert WHERE id=%i", $id);
			$this->nameModel->clear('concert', array('name_id', 'place_name_id', 'text_name_id'));
		} catch(Exception $ex) {
			$this->db->rollback();
			throw $ex;
		}
		$this->db->commit();
		return $this;
	}
}
