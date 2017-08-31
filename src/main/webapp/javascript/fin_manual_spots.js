
var finSpots = {
    ctx: null,
    ctrl: null,
    imgEl: null,
    pickerPoints: [],
    sizeRatio: 1,
    forceFlip: false,

    pickPoints: function (img, canv) {
	finSpots.imgEl = img;
	finSpots.sizeRatio = img.naturalWidth / img.width;
	finSpots.ctrl = document.createElement('div');
	finSpots.ctrl.className = 'picker-controls';
	var h = '<input type="button" onClick="pickerCancel()" value="cancel" />';
	h += '<input type="button" onClick="pickerReset()" value="reset" />';
	h += '<input type="button" onClick="pickerSave()" value="save" />';
	h += '<input type="button" onClick="pickerFlip()" value="&harr;" />';
	h += '<div id="picker-info"></div>';
	img.parentElement.appendChild(finSpots.ctrl);
	finSpots.ctrl.innerHTML = h;
	finSpots.ctx = canv.getContext('2d');
	img.addEventListener('click', function(ev) {
		finSpots.pickerClick(ev);
	});
    },

    pickerReset: function() {
	finSpots.forceFlip = false;
	finSpots.pickerPoints = [];
	finSpots.pickerClear();
    },

    pickerCancel: function() {
	finSpots.pickerReset();
	finSpots.ctrl.remove();
	finSpots.ctx.canvas.remove();
    },

    pickerClick: function(ev) {
	if (finSpots.pickerPoints.length > 2) return;
	finSpots.pickerPoints.push([ev.offsetX, ev.offsetY]);
//console.log(pickerPoints);
	finSpots.pickerOrderPoints();
//console.log(pickerPoints);
	finSpots.pickerDrawPoints();
    },

    pickerFlip: function() {
	finSpots.forceFlip = !finSpots.forceFlip;
	finSpots.pickerOrderPoints();
	finSpots.pickerDrawPoints();
    },

    pickerOrderPoints: function() {
	if (finSpots.pickerPoints.length < 1) return;
	var tip = 0;
	for (var i = 1 ; i < finSpots.pickerPoints.length ; i++) {
		if (finSpots.pickerPoints[i][1] < finSpots.pickerPoints[tip][1]) tip = i;
	}
console.info('tip = %d', tip);
	var closestValue = 9999999;
	var closest = -1;
	for (var i = 0 ; i < finSpots.pickerPoints.length ; i++) {
		if (i == tip) continue;
		var diff = Math.abs(finSpots.pickerPoints[i][0] - finSpots.pickerPoints[tip][0]);
		if (diff < closestValue) {
			closest = i;
			closestValue = diff;
		}
	}
	console.info('closest = %d', closest);
	var newPts = [finSpots.pickerPoints[tip]];
	if (closest >= 0) {
		if (finSpots.pickerPoints.length > 2) {
			newPts.push(finSpots.pickerPoints[3 - tip - closest]);
			newPts.push(finSpots.pickerPoints[closest]);
		} else {
			newPts.push(finSpots.pickerPoints[closest]);
		}
	}
	if (finSpots.forceFlip && (newPts.length > 2)) {
		var x = newPts[1];
		newPts[1] = newPts[2];
		newPts[2] = x;
	}
console.info('final pts: %o', newPts);
	finSpots.pickerPoints = newPts;
    },

    pickerDrawPoints: function() {
	finSpots.pickerClear();
	if (finSpots.pickerPoints.length > 0) {
		finSpots.ptAt(finSpots.pickerPoints[0]);
		finSpots.labelAt(finSpots.pickerPoints[0], 'tip');
	}
	if (finSpots.pickerPoints.length > 1) {
		finSpots.ptAt(finSpots.pickerPoints[1]);
		finSpots.labelAt(finSpots.pickerPoints[1], 'front');
	}
	if (finSpots.pickerPoints.length > 2) {
		finSpots.ptAt(finSpots.pickerPoints[2]);
		finSpots.labelAt(finSpots.pickerPoints[2], 'back');
	}
    },

    pickerClear: function() {
	finSpots.ctx.clearRect(0, 0, finSpots.ctx.canvas.width, finSpots.ctx.canvas.height);
	var l = document.getElementsByClassName('picker-label');
	for (var i = l.length - 1 ; i >= 0 ; i--) {
		l[i].remove();
	}
    },

    ptAt: function(xy) {
	finSpots.ctx.beginPath();
	finSpots.ctx.arc(xy[0], xy[1], 4, 0, 2 * Math.PI);
	finSpots.ctx.fillStyle = 'rgba(255,255,0,0.8)';
	//ctx.fillStyle = '#FF0';
	finSpots.ctx.fill();
    },

    labelAt: function(xy, txt) {
	var l = document.createElement('div');
	l.className = 'picker-label';
	l.innerHTML = txt;
	l.style.left = xy[0];
	l.style.top = xy[1] - 15;
	finSpots.imgEl.parentElement.appendChild(l);
    },

    init: function() {
	finSpots.pickPoints(document.getElementById('img'), document.getElementById('canv'));
    }
};

