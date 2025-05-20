import { writable } from 'svelte/store';

// User store
export const currentUser = writable(null);

// Blood pressure records store
export const bpRecords = writable([]);

// Alerts store
export const alerts = writable([]);

// Blood pressure categories
export const bpCategories = {
    normal: { min: [0, 0], max: [130, 85], label: "Normalt", class: "pressure-normal" },
    highNormal: { min: [130, 85], max: [140, 90], label: "Høyt normalt", class: "pressure-high-normal" },
    high: { min: [140, 90], max: [180, 110], label: "Forhøyet", class: "pressure-high" },
    veryHigh: { min: [180, 110], max: [300, 200], label: "Alvorlig forhøyet", class: "pressure-very-high" }
};

// Utility functions
export function generateUniqueId() {
    return Math.random().toString(36).substr(2, 9);
}

export function categorizeBP(sys, dia) {
    if (sys >= 180 || dia >= 110) {
        return { key: 'veryHigh', ...bpCategories.veryHigh };
    } else if (sys >= 140 || dia >= 90) {
        return { key: 'high', ...bpCategories.high };
    } else if (sys >= 130 || dia >= 85) {
        return { key: 'highNormal', ...bpCategories.highNormal };
    } else {
        return { key: 'normal', ...bpCategories.normal };
    }
}

export function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString('nb-NO');
}

export function formatTime(timeString) {
    return timeString || new Date().toLocaleTimeString('nb-NO', { hour: '2-digit', minute: '2-digit' });
}

// Alert management
export function showAlert(message, type = 'success') {
    alerts.update(currentAlerts => [
        ...currentAlerts,
        { id: generateUniqueId(), message, type, timestamp: Date.now() }
    ]);
    
    // Auto-remove after 5 seconds
    setTimeout(() => {
        alerts.update(currentAlerts => 
            currentAlerts.filter(alert => 
                Date.now() - alert.timestamp < 5000
            )
        );
    }, 5000);
}