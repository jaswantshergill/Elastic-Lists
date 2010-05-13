package eu.stefaner.elasticlists.ui.facetboxes.geo {	import eu.stefaner.elasticlists.data.FacetValue;	import eu.stefaner.elasticlists.data.GeoFacetValue;	import eu.stefaner.elasticlists.ui.facetboxes.FacetBox;	import eu.stefaner.elasticlists.ui.facetboxes.FacetBoxElement;	import com.modestmaps.TweenMap;	import com.modestmaps.core.MapExtent;	import com.modestmaps.events.MapEvent;	import com.modestmaps.extras.ZoomSlider;	import com.modestmaps.mapproviders.OpenStreetMapProvider;	import flash.events.Event;	import flash.events.MouseEvent;	import flash.filters.ColorMatrixFilter;	public class GeoFacetBox extends FacetBox {		public var MIN_ZOOM : Number = 3;
		public var MAX_ZOOM : int = 12;
		public var visibleRect : MapExtent;		private var map : TweenMap;		public function GeoFacetBox() {			super();		}		//---------------------------------------		// GETTER / SETTERS		//---------------------------------------		override public function set height( h : Number ) : void { 			bg.height = h;			if(map) {				map.setSize(bg.width, bg.height);			}		}			override public function set width( w : Number ) : void { 			bg.width = w;			if(map) {				map.setSize(bg.width, bg.height);			}		}		override protected function initGraphics() : void {
			super.initGraphics();			initMap();
		}
		override public function onFacetBoxElementClick(target : FacetBoxElement) : void {			/*			var r=(facet as GeoFacet).visibleRect;			map.setExtent(new MapExtent(r.top, r.bottom, r.right, r.left));			 */			for each (var f:GeoFacetValue in facet.facetValues) {				f.selected = false;			}			if(!target.selected) {				target.selected = true;				//map.setCenter((target as MapMarker).location);				//map.setZoom(MAX_ZOOM);				map.panAndZoomBy(MAX_ZOOM - map.grid.zoomLevel, (target as MapMarker).location, null, transitioner.duration);								updateFiltersFromVisibleArea(); 			} else {				doPositioning();			}		}		override protected function createFacetBoxElement(facetValue : FacetValue) : FacetBoxElement {			var sprite : MapMarker;						sprite = MapMarker(getNewFacetBoxElement());			sprite.init(this, facetValue);			map.putMarker(sprite.location, sprite);						facetBoxElements.push(sprite);			facetBoxElementForDataObject[facetValue] = sprite;						return sprite;		}		override protected function getNewFacetBoxElement() : FacetBoxElement {			return new MapMarker();		}		//---------------------------------------		// OTHER STUFF		//---------------------------------------		protected function initMap() : void {				/*			map = new Map(bg.width, bg.height, true, new OpenStreetMapProvider());			addChild(map);			map.addChild(new MapControls(map));			 */			map = new TweenMap(bg.width, bg.height, true, new OpenStreetMapProvider(MIN_ZOOM, MAX_ZOOM));					//map.addChild(new MapCopyright(map, 143, 10));			//map.addChild(new ZoomBox(map));			map.addChild(new ZoomSlider(map));			//map.addChild(new NavigatorWindow(map));			//map.addChild(new MapControls(map));			//map.addChild(new MapScale(map, 140));			map.addEventListener(MouseEvent.DOUBLE_CLICK, map.onDoubleClick);			map.addEventListener(MouseEvent.MOUSE_WHEEL, map.onMouseWheel); 			// listen for map events			map.addEventListener(MapEvent.STOP_ZOOMING, onMapChange);			map.addEventListener(MapEvent.STOP_PANNING, onMapChange);			/*			var ct : ColorTransform = new ColorTransform(0, 0, 0, 1, 150, 150, 150, 0);			map.grid.transform.colorTransform = ct;			 * 			 */			map.grid.filters = [new ColorMatrixFilter([0.4230688,0.6142752,0.082656,0,20.38,0.3110688,0.7262752,0.082656,0,20.38,0.3110688,0.6142752,0.194656,0,20.38,0,0,0,1,0])];			addChild(map);		};		private function onMapChange(e : MapEvent) : void {			updateFiltersFromVisibleArea();		};		private function updateFiltersFromVisibleArea() : void {			this.visibleRect = map.getExtent();			/*			 // need to improve this			for each (var f:GeoFacetValue in data) {				f.selected = f.isInRegion(this.visibleRect);			}						dispatchEvent(new Event(FacetBox.SELECTION_CHANGE));			 * 			 */		};		override protected function doPositioning() : void {			//map.setSize(bg.width, bg.height);			var r : MapExtent = getVisibleExtent();			//map.setExtent(r);			map.tweenExtent(r, transitioner.duration);			 /*			trace("MAP ZOOM " + map.getZoom());			var z : int = map.getZoom(); 			for each (var sprite:MapMarker in facetBoxElements) {				sprite.scaleX = sprite.scaleY = .5 + Math.sqrt(z) * .5;			}			 * 			 */		};		private function getVisibleExtent() : MapExtent {			var m : MapExtent;								for each(var f:GeoFacetValue in facet.facetValues) {				// TODO: does not respect the case where facetvalue might be hidden because of maxItems contraint 				if(f.numContentItems) {					if(m == null) m = new MapExtent(f.lat, f.lat, f.long, f.long);					m.enclose(f.location);				}			}			if(m == null) m = new MapExtent();			var padding : Number = 1;			m.north -= padding;			m.west -= padding;			m.south += padding;			m.east += padding;						 			return m;		}						//	GETTERS/SETTERS:				//	PRIVATE METHODS:	}}