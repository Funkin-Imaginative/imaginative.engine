package fnf.utils;

class FailsafeUtil {
	// idk why I did this lmao https://www.dcode.fr/keyboard-smash
	@:unreflective public static final invaildScriptKey:String = 'DSSDREW GFDGFDTRRTASDDSA FDSFDSWXCWXCERTERT FDSSDFWXCWXCFDS FDDFKLMKLMKLM MLKKLM[POOP[ POPOASD KJHDSSDKJHPOI WECXWCXW SDSDEWQFDSFDS SDFERTTRE DSADFGSDF KJHOIUUIO SDFGFDFGGFFDS DFGJKLKLMLM;;ML OP[OP[GFDDFGDFGGFD LKJPOPOUIOLKJLKJ LKJPOIIOPLKJASD DSAASDLKJLKJPOI KJHHJKJKLJKL OP[SAAS SDFSDFGFDDFGDSDS ERTTRRTFDSFDS JKLJKLSDF EWQEWQIOPWXCWXC JKLLKJSD SDFGFGFOIUUIO LKJDSAASDDSASDF LM;LM;IUUI FDSLKJMLK DSSDDFGDFG EWQGFDGFD SDFSDFASDASDKL MLKFDSFDS LKJJKLLKJ SDFEROP[ IOPIOPJKLLKJLKJLKJ JKJKSDFSDFTRE EWQOIIOLKJKLM ASDERTSDFIUUI OPJKLIO FDFDSDF REWJKKJLM;UIO JKLJKLKLKLLK KLLKJLKJ EWNM,POOP [POLKJKLMMLK ASDDSADFGLKJLKJLKJ SDFFDSLKJ LM;LM;LKJ';

	public static final charYaml:fnf.objects.Character.CharYaml = {
		sprite: 'BOYFRIEND',
		flip: true,
		anims: [{name: 'idle', tag: 'BF idle dance', fps: 24, loop: false, offset: {x: -5, y: 0}, indices: []}],
		position: {x: 0, y: 350},
		camera: {x: 0, y: 0},

		scale: 1,
		singLen: 4,
		icon: 'face',
		aliasing: true,
		color: '',
		beat: 0
	};
}