# rive_pull_to_refresh

<div align="center">
	<a href="https://flutter.io">
    	<img src="https://img.shields.io/badge/Platform-Flutter-blue"/>
	<a href="https://github.com/phucho236/RivePullToRefresh/blob/main/LICENSE">
    	<img src="https://img.shields.io/badge/MIT-LICENSE-orange"/>
	<a href="https://pub.dev/documentation/rive_pull_to_refresh/latest/rive_pull_to_refresh/rive_pull_to_refresh-library.html">
    	<img src="https://img.shields.io/badge/Documentation-Library-blue" />
</div>
		
# Intro

- A custom refresh indicator with Rive, Image, GIF...
- Integrate rive quickly
- Provides callbacks for the pull-to-refresh action:\
	value when the client pulls down or pulls up.\
	stop scrolling\
	close header...
- Customize\
	floating, header mode.\
	percent resize to activate refresh.\
	Duration, Cuver...
<div align="center">
	<table>
		<thead>
			<tr>
			<th style="text-align:center"><code>planet-header</code></th>
			<th style="text-align:center"><code>planet-floating</code></th>
			<th style="text-align:center"><code>planet-bottom</code></th>
			</tr>
		</thead>
		<tbody>
			<tr>
			<td style="text-align:center"><img src="https://github.com/phucho236/RivePullToRefresh/blob/main/assets/planet_header.gif?raw=true" height = "500px"/></td>
			<td style="text-align:center"><img src="https://github.com/phucho236/RivePullToRefresh/blob/main/assets/planet_floating.gif?raw=true" height = "500px"/></td>
			<td style="text-align:center"><img src="https://github.com/phucho236/RivePullToRefresh/blob/main/assets/planet_bottom.gif?raw=true" height = "500px"/></td>
			</tr>
		</tbody>
	</table>
</div>
<div align="center">
	<table>
		<thead>
			<tr>
			<th style="text-align:center"><code>bow</code></th>
			<th style="text-align:center"><code>space</code></th>
			<th style="text-align:center"><code>lipid</code></th>
			</tr>
		</thead>
		<tbody>
			<tr>
			<td style="text-align:center"><img src="https://github.com/phucho236/RivePullToRefresh/blob/main/assets/liquid.gif?raw=true" height = "500px"/></td>
			<td style="text-align:center"><img src="https://github.com/phucho236/RivePullToRefresh/blob/main/assets/bow.gif?raw=true" height = "500px"/></td>
			<td style="text-align:center"><img src="https://github.com/phucho236/RivePullToRefresh/blob/main/assets/space.gif?raw=true" height = "500px"/></td>
			</tr>
		</tbody>
	</table>
</div>
<div align="center">
	<table>
		<thead>
			<tr>
			<th style="text-align:center"><code>liquid_v1</code></th>
			</tr>
		</thead>
		<tbody>
			<tr>
			<td style="text-align:center"><img src="https://github.com/phucho236/RivePullToRefresh/blob/main/assets/lipid.gif?raw=true" height = "500px"/></td>
			<td style="text-align:center"><img src="https://github.com/phucho236/RivePullToRefresh/blob/main/assets/liquid_v1.gif?raw=true" height = "500px"/></td>
			</tr>
		</tbody>
	</table>
</div>

# Wanrning
- You must know a little bit of rive. If not you can use the existing rive files in the example(can't edit color from Flutter).

# Flutter

### 1. Depend on it
Add this to your package's `pubspec.yaml` file:
```yaml
rive_pull_to_refresh: ^1.0.3+3
```

### 2. Install it
You can install packages from the command line:\
with `dart`:

```css
dart pub get
```

with `Flutter`:

```css
flutter pub get
```

### 3. Import it
```dart
import 'package:rive_pull_to_refresh/rive_pull_to_refresh.dart';
```
### 4. Physics
BouncingScrollPhysics(physics default of ios) makes the package work not correctly so please set the physics of Scrolling widgets
```dart
ListView.builder(
          physics: const ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
...
```
# Rive
Check editor Rive to know State Machine and Inputs [here](https://rive.app/community/files/8964-pull-to-refresh/)
# Example use rive file from:

[JcToon](https://rive.app/@JcToon/) : [community](https://rive.app/community/3146-6725-pull-to-refresh/)\
[Drawsgood](https://rive.app/@drawsgood/) : [community](https://rive.app/community/5251-10495-pull-to-refresh-use-case/)\
[RiveExamples](https://rive.app/@RiveExamples/) : [community](https://rive.app/community/516-982-interactive-animations/)\
Thank all.

# Support the package(optional)
<div  align="left">
	<h6>If you find this package useful.<br>You can support it by giving it a thumbs up or buy me a coffee.<br>Thank you !</\h6><br>
  	<a href="https://www.paypal.com/paypalme/phucho2306">
    	<img src="https://img.shields.io/badge/Donate-Paypal-blue"alt="Donate" />
	<a href="https://me.momo.vn/G9IguZfofzt3CdtWuMu7">
    	<img src="https://img.shields.io/badge/Donate-Momo-D82d88"alt="Donate" />
</div>

