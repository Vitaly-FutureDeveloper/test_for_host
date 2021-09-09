$(document).ready(function() {
	const ORGANIZATIONS = [ [1, "Lada"], [2, "Audi"], [3, "Toyoya"] ];
	const FUNC_WORKERS = [ [10, "Директор"], [20, "Инженер"], [30, "Менеджер"] ];
	
	// Идентификатор,	ФИО,	Ид. организации,	Ид. дожности
	const WORKERS = [
		[1, "Сидоров Иван Петрович",  1, 10],
		[2, "Клюквина Анастасия Викторовна", 1, 30],
		[3, "Yoshimoro Katsumi", 3, 10],
		[4, "Albrecht Wallenstein", 2, 20],
		[5, "Архипов Федот Ярополкович", 1, 20],
		[6, "Синицына Ксения Игоревна", 1, 30],
		[7, "Gustaf Grefberg", 2, 10],
		[8, "Simidzu Koyama", 3, 20],
		[9, "Miura Hirana", 3, 20],
		[10, "Кузьмин Егор Владимирович", 1, 30],
		[11, "Мазурик Алёна Васильевна", 1, 20],
		[12, "Gudrun Ensslin", 2, 30],
		[13, "Ernst Rommel", 2, 20]
	];

	$('.js-select-org').on('change', inputOrganization);
	$('.js-checkbox').on('change', inputOrganization);

	$('.js-output').on('click', appendWorker);
	$('.js-reset').on('click', clearWorker);
	
	function inputOrganization() {
		const select = document.querySelector('.js-select-org');
		const cooperators_select =
			document.querySelector('.js-select-cooperators');
		const id_select = getChoosedIdOrganization(select);

		if(id_select > 0){
			const checked = document.querySelectorAll('.js-checkbox:checked');
			const filteredArray = getFinedArrayWorkers(WORKERS, id_select, checked);

			cooperators_select.disabled = false;
			cooperators_select.innerHTML = '';

			render(filteredArray, getOptionsComponent, cooperators_select);
		} else {
			cooperators_select.disabled = true;
		}
	}

	function appendWorker(evt){
		evt.preventDefault();

		const output = document.querySelector('.js-output-block');
		const cooperators_select =
			document.querySelector('.js-select-cooperators');
		const id_select = getChoosedIdOrganization(cooperators_select);

		let filteredArray = getFinedArrayId(WORKERS, id_select);
		let filteredOrg = getFinedArrayId(ORGANIZATIONS, filteredArray[0][2]);
		let filteredFunc = getFinedArrayId(FUNC_WORKERS, filteredArray[0][3]);

		let array = [];
		array.push(filteredArray[0][1]);
		array.push(filteredOrg[0][1]);
		array.push(filteredFunc[0][1]);
		array = [[...array]];

		render(array, getOutputComponent, output);
	}

	function clearWorker(evt) {
		evt.preventDefault();
		const output = document.querySelector('.js-output-block');
		output.innerHTML = '';
	}

	function getChoosedIdOrganization(select) {
		return select.value;
	}

	function getFinedArrayId(array, id_select){
		const filtered = array.filter((item) => {
			return item[0] == id_select;
		});

		return filtered;
	}

	function getFinedArrayWorkers(array, id_select, checked=null) {
		// @array : [] ,
		// @id_select : Num - Выбранная организация ,
		// @checked : DOM - Выбранные чекбоксы должность

		const filtered = array.filter((item) => {
			return item[2] == id_select;
		});

		let filtered_check = filtered;

		if(checked && checked[0]) {
			// Если выбран хоть 1 чекбокс
			filtered_check = filtered.filter((item) => {
				const check = (checked[0] && item[3] == checked[0].value) ||
					(checked[1] && item[3] == checked[1].value) ||
					(checked[2] && item[3] == checked[2].value);

				return check;
			});
		}
		// console.log(filtered);
		// console.log(filtered_check);

		return filtered_check;
	}

	function render(array, componentFunc, DOMParent) {
		let fragment = document.createDocumentFragment();
		for(let item of array) {
			let element = componentFunc(item);
			fragment.appendChild(element);
		}
		DOMParent.appendChild(fragment);
	}

	function getOptionsComponent(obj) {
		const [id, text, id_organization, id_work] = obj;
		const option = document.createElement('option');

		option.value = id;
		option.textContent = text;
		option.setAttribute('data-id_organization', id_organization);
		option.setAttribute('data-id_work', id_work);

		return option;
	}
	function getOutputComponent(obj) {
		const [text, work, organization] = obj;

		const p = document.createElement('p');
		p.classList.add('uotput__text');
		p.textContent = `${text} - ${work} (${organization})`;

		return p;
	}

});