
export function sendRequest(action, data, done) {

	let formData = new FormData();
	formData.append('action', action);
	formData.append('data', JSON.stringify(data));

	let request = new XMLHttpRequest();
	request.addEventListener("load", () => {
		if(done != null) {
			done(JSON.parse(request.responseText));
		}
	});
	request.open("POST", window.baseUrl);
	request.send(formData);
}