import React, { useMemo, useState } from 'react';
import { MapContainer, TileLayer, Marker, Popup, useMap } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';

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
    // Add more as needed
};

// Create custom icon with job count
const createCustomIcon = (jobCount) => {
    return L.divIcon({
        className: 'custom-marker',
        html: `
            <div style="
                background: linear-gradient(135deg, #10b981 0%, #059669 100%);
                color: white;
                border-radius: 50%;
                width: 40px;
                height: 40px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-weight: bold;
                font-size: 14px;
                box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1), 0 2px 4px rgba(0, 0, 0, 0.06);
                border: 3px solid white;
            ">
                ${jobCount}
            </div>
        `,
        iconSize: [40, 40],
        iconAnchor: [20, 20],
        popupAnchor: [0, -20]
    });
};

const JobLocationMap = ({ data }) => {
    const markers = useMemo(() => {
        if (!data || !Array.isArray(data)) return [];

        return data.map(item => {
            // Normalize location string to match keys if possible
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

    if (!data || data.length === 0) {
        return (
            <div className="bg-blue-50 border border-blue-200 rounded-xl p-6 text-center text-blue-600">
                <p className="font-semibold">Chưa có dữ liệu địa điểm</p>
                <p className="text-sm mt-1">Dữ liệu sẽ hiển thị khi có việc làm được đăng tuyển.</p>
            </div>
        );
    }

    return (
        <div style={containerStyle} className="rounded-xl overflow-hidden shadow-sm">
            <MapContainer
                center={[center.lat, center.lng]}
                zoom={6}
                style={{ width: '100%', height: '100%' }}
                scrollWheelZoom={true}
                zoomControl={true}
            >
                <TileLayer
                    attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
                    url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                />

                {markers.map((marker, index) => (
                    <Marker
                        key={index}
                        position={[marker.lat, marker.lng]}
                        icon={createCustomIcon(marker.jobCount)}
                    >
                        <Popup>
                            <div className="p-2">
                                <h3 className="font-bold text-gray-900 text-base mb-1">
                                    {marker.location}
                                </h3>
                                <p className="text-sm text-gray-600">
                                    <span className="font-semibold text-emerald-600">
                                        {marker.jobCount}
                                    </span> việc làm đang tuyển
                                </p>
                            </div>
                        </Popup>
                    </Marker>
                ))}
            </MapContainer>
        </div>
    );
};

export default React.memo(JobLocationMap);
