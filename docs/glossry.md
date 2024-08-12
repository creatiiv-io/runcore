# Words and Concept


- Service Containers
- Settings Overlays
- Deployment Settings
- Developer Registration



## Settings Overlays

The settings system creates several overlay files. These can work together to create a complex system of settings. The `default` overlay is loaded first followed by a named overlay if specified my `runcore overlay [name]` and finally an `override` overlay which forces the settings to be overridden. The `override` overlay is not really much. But it is helpful when packaging your application for redistribution.

## Settings Format

Each setting is named with a category then a dot then a name followed by a colon and the value of the setting. There are several default categories.


