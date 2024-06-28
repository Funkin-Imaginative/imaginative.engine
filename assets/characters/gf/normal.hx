function update(elapsed:Float)
	if (getAnimName() == 'hairBlow' && isAnimFinished())
		playAnim('hairFall', true);

function playingAnimPost(event)
	if (event.anim == 'hairFall')
		onSway = true;