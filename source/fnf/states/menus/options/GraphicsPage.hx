package fnf.states.menus.options;

class GraphicsPage extends PageTemplate {
	public function new() {
		super('graphics');
	}

	override function onPrefCreation() {
		// createPrefItem('Quality Level', 'qualityLevel', 1);
		createPrefItem('Allow Shaders', 'enableShaders', true);
		createPrefItem('Allow Aliasing', 'allowAliasing', true);
		createPrefItem('Cache via GPU', 'cacheGPU', false);
		// createPrefItem('FPS Type', 'fpsType', 'Capped');
		// createPrefItem('FPS Cap', 'fpsCap', 60);
	}
}