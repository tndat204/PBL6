import React, { useMemo } from 'react';
import { GoogleMap, Marker, useJsApiLoader, InfoWindow } from '@react-google-maps/api';

const containerStyle = {
    width: '100%',
    height: '500px',
    borderRadius: '0.75rem'
};

const center = {
    lat: 16.047079,
    lng: 108.206230 // Center of Vietnam (approx Da Nang)
};

// Hardcoded coordinates for major cities
const CITY_COORDINATES = {
    'Hà Nội': { lat: 21.0285, lng: 105.8542 },
    'Ha Noi': { lat: 21.0285, lng: 105.8542 },
    'Hanoi': { lat: 21.0285, lng: 105.8542 },
    'Hồ Chí Minh': { lat: 10.8231, lng: 106.6297 },
    'Ho Chi Minh': { lat: 10.8231, lng: 106.6297 },
    'TP. Hồ Chí Minh': { lat: 10.8231, lng: 106.6297 },
    'TP HCM': { lat: 10.8231, lng: 106.6297 },
    'Đà Nẵng': { lat: 16.0544, lng: 108.2022 },
    'Da Nang': { lat: 16.0544, lng: 108.2022 },
    'Cần Thơ': { lat: 10.0452, lng: 105.7469 },
    'Can Tho': { lat: 10.0452, lng: 105.7469 },
    'Hải Phòng': { lat: 20.8449, lng: 106.6881 },
    'Hai Phong': { lat: 20.8449, lng: 106.6881 },
    // Add more as needed or use a geocoding service in the future
};

const JobLocationMap = ({ data }) => {
    const { isLoaded } = useJsApiLoader({
        id: 'google-map-script',
        googleMapsApiKey: import.meta.env.VITE_GOOGLE_MAPS_API_KEY || ''
    });

    const [selectedLocation, setSelectedLocation] = React.useState(null);

    const markers = useMemo(() => {
        if (!data || !Array.isArray(data)) return [];

        return data.map(item => {
            // Normalize location string to match keys if possible, or simple lookup
            // This is a basic implementation. Ideally, backend should return lat/lng or we use Geocoding API.
            const coords = CITY_COORDINATES[item.location] ||
                Object.entries(CITY_COORDINATES).find(([key]) => item.location.includes(key))?.[1];

            if (coords) {
                return {
                    ...coords,
                    ...item
                };
            }
            return null;
        }).filter(Boolean);
    }, [data]);

    const onLoad = React.useCallback(function callback(map) {
        // const bounds = new window.google.maps.LatLngBounds(center);
        // map.fitBounds(bounds);
        // setMap(map)
    }, [])

    const onUnmount = React.useCallback(function callback(map) {
        // setMap(null)
    }, [])

    if (!import.meta.env.VITE_GOOGLE_MAPS_API_KEY) {
        return (
            <div className="bg-red-50 border border-red-200 rounded-xl p-6 text-center text-red-600">
                <p className="font-semibold">Google Maps API Key is missing.</p>
                <p className="text-sm mt-1">Please add VITE_GOOGLE_MAPS_API_KEY to your .env file.</p>
            </div>
        );
    }

    if (!isLoaded) {
        return (
            <div className="w-full h-[500px] bg-gray-100 rounded-xl flex items-center justify-center animate-pulse">
                <p className="text-gray-500">Loading Map...</p>
            </div>
        );
    }

    return (
        <GoogleMap
            mapContainerStyle={containerStyle}
            center={center}
            zoom={6}
            onLoad={onLoad}
            onUnmount={onUnmount}
            options={{
                streetViewControl: false,
                mapTypeControl: false,
            }}
        >
            {markers.map((marker, index) => (
                <Marker
                    key={index}
                    position={{ lat: marker.lat, lng: marker.lng }}
                    onClick={() => setSelectedLocation(marker)}
                    label={{
                        text: marker.jobCount.toString(),
                        color: "white",
                        fontWeight: "bold",
                        fontSize: "14px"
                    }}
                />
            ))}

            {selectedLocation && (
                <InfoWindow
                    position={{ lat: selectedLocation.lat, lng: selectedLocation.lng }}
                    onCloseClick={() => setSelectedLocation(null)}
                >
                    <div className="p-2">
                        <h3 className="font-bold text-gray-900">{selectedLocation.location}</h3>
                        <p className="text-sm text-gray-600">
                            <span className="font-semibold text-blue-600">{selectedLocation.jobCount}</span> việc làm đang tuyển
                        </p>
                    </div>
                </InfoWindow>
            )}
        </GoogleMap>
    );
};

export default React.memo(JobLocationMap);
