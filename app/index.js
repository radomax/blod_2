// Blood pressure records database
        let bpRecords = [];
        let currentUser = null;

        // Blood pressure categories
        const bpCategories = {
            normal: { min: [0, 0], max: [130, 85], label: "Normalt", class: "pressure-normal" },
            highNormal: { min: [130, 85], max: [140, 90], label: "Høyt normalt", class: "pressure-high-normal" },
            high: { min: [140, 90], max: [180, 110], label: "Forhøyet", class: "pressure-high" },
            veryHigh: { min: [180, 110], max: [300, 200], label: "Alvorlig forhøyet", class: "pressure-very-high" }
        };

        // Utility functions
        function generateUniqueId() {
            return Math.random().toString(36).substr(2, 9);
        }

        function showAlert(message, type = 'success') {
            const alertsContainer = document.getElementById('alerts');
            const alertElement = document.createElement('div');
            alertElement.className = `alert alert-${type}`;
            alertElement.textContent = message;
            alertsContainer.appendChild(alertElement);

            setTimeout(() => {
                alertElement.remove();
            }, 5000);
        }

        function formatDate(dateString) {
            const date = new Date(dateString);
            return date.toLocaleDateString('nb-NO');
        }

        function formatTime(timeString) {
            return timeString || new Date().toLocaleTimeString('nb-NO', { hour: '2-digit', minute: '2-digit' });
        }

        function categorizeBP(sys, dia) {
            for (const [key, category] of Object.entries(bpCategories)) {
                if (sys >= category.min[0] && dia >= category.min[1] && 
                    sys < category.max[0] && dia < category.max[1]) {
                    return { key, ...category };
                }
            }
            return { key: 'veryHigh', ...bpCategories.veryHigh };
        }

        // Event listeners
        document.addEventListener('DOMContentLoaded', function() {
            // Set today's date as default
            document.getElementById('measurementDate').value = new Date().toISOString().split('T')[0];
            document.getElementById('measurementTime').value = new Date().toLocaleTimeString('en-US', { hour12: false, hour: '2-digit', minute: '2-digit' });

            // Navigation
            const navLinks = document.querySelectorAll('.nav-link');
            const tabContents = document.querySelectorAll('.tab-content');
            
            navLinks.forEach(link => {
                link.addEventListener('click', function(e) {
                    e.preventDefault();
                    const targetId = this.getAttribute('data-target') + 'Section';
                    
                    tabContents.forEach(content => {
                        content.classList.remove('active');
                    });
                    
                    document.getElementById(targetId).classList.add('active');
                    
                    navLinks.forEach(navLink => {
                        navLink.classList.remove('active');
                    });
                    this.classList.add('active');

                    // Load data if switching to visualize section
                    if (this.getAttribute('data-target') === 'visualize') {
                        updateStatistics();
                    }
                });
            });

            // Modal handling
            const modalClosers = document.querySelectorAll('.modal-close, .modal-close-btn');
            modalClosers.forEach(closer => {
                closer.addEventListener('click', function() {
                    const modal = this.closest('.modal-backdrop');
                    modal.style.display = 'none';
                });
            });

            // Login functionality
            document.getElementById('loginLink').addEventListener('click', function(e) {
                e.preventDefault();
                if (currentUser) {
                    logout();
                } else {
                    document.getElementById('loginModal').style.display = 'flex';
                }
            });

            document.getElementById('loginButton').addEventListener('click', function() {
                const username = document.getElementById('username').value;
                const password = document.getElementById('password').value;
                const role = document.getElementById('role').value;
                
                if (username && password) {
                    currentUser = { username, role };
                    document.getElementById('loginModal').style.display = 'none';
                    showAlert(`Innlogget som ${username} (${role === 'admin' ? 'Administrator' : 'Ansatt'})`);
                    
                    // Update UI based on role
                    updateUIForUser();
                } else {
                    showAlert('Vennligst fyll ut alle feltene', 'error');
                }
            });

            function logout() {
                currentUser = null;
                showAlert('Du er nå logget ut');
                updateUIForUser();
                // Go back to registration page
                navLinks[0].click();
            }

            function updateUIForUser() {
                const loginLink = document.getElementById('loginLink');
                const nav = document.querySelector('nav ul');
                
                if (currentUser) {
                    loginLink.textContent = 'Logg ut';
                    
                    if (currentUser.role === 'admin') {
                        // Add admin link if not exists
                        if (!document.querySelector('.nav-link[data-target="recordList"]')) {
                            const adminLi = document.createElement('li');
                            const adminLink = document.createElement('a');
                            adminLink.href = '#';
                            adminLink.className = 'nav-link';
                            adminLink.setAttribute('data-target', 'recordList');
                            adminLink.textContent = 'Administrer';
                            adminLi.appendChild(adminLink);
                            nav.insertBefore(adminLi, loginLink.parentElement);
                            
                            // Add event listener
                            adminLink.addEventListener('click', function(e) {
                                e.preventDefault();
                                tabContents.forEach(content => {
                                    content.classList.remove('active');
                                });
                                document.getElementById('recordListSection').classList.add('active');
                                navLinks.forEach(navLink => {
                                    navLink.classList.remove('active');
                                });
                                this.classList.add('active');
                                loadRecordsTable();
                            });
                        }
                    }
                } else {
                    loginLink.textContent = 'Logg inn';
                    // Remove admin link
                    const adminLink = document.querySelector('.nav-link[data-target="recordList"]');
                    if (adminLink) adminLink.parentElement.remove();
                }
            }

            // Auto-calculate average when measurements change
            const measurementInputs = [
                'measurement2Sys', 'measurement2Dia', 
                'measurement3Sys', 'measurement3Dia'
            ];
            
            measurementInputs.forEach(id => {
                document.getElementById(id).addEventListener('input', calculateAverage);
            });

            function calculateAverage() {
                const sys2 = parseInt(document.getElementById('measurement2Sys').value);
                const dia2 = parseInt(document.getElementById('measurement2Dia').value);
                const sys3 = parseInt(document.getElementById('measurement3Sys').value);
                const dia3 = parseInt(document.getElementById('measurement3Dia').value);

                if (sys2 && dia2 && sys3 && dia3) {
                    const avgSys = Math.round((sys2 + sys3) / 2);
                    const avgDia = Math.round((dia2 + dia3) / 2);
                    
                    const category = categorizeBP(avgSys, avgDia);
                    
                    document.getElementById('averageResult').style.display = 'block';
                    document.getElementById('averageDisplay').innerHTML = 
                        `<strong>${avgSys}/${avgDia} mmHg</strong>`;
                    document.getElementById('pressureCategory').innerHTML = 
                        `<span class="pressure-status ${category.class}">${category.label}</span>`;
                }
            }

            // Form submission
            document.getElementById('bpForm').addEventListener('submit', function(e) {
                e.preventDefault();
                
                // Validate form
                const formData = collectFormData();
                if (!validateFormData(formData)) {
                    return;
                }

                // Save record
                const newRecord = {
                    id: generateUniqueId(),
                    ...formData,
                    registeredAt: new Date().toISOString(),
                    registeredBy: currentUser ? currentUser.username : 'Ukjent'
                };

                bpRecords.push(newRecord);
                showAlert('Blodtrykksmåling lagret');
                this.reset();
                
                // Reset calculated values
                document.getElementById('averageResult').style.display = 'none';
                
                // Set default values again
                document.getElementById('measurementDate').value = new Date().toISOString().split('T')[0];
                document.getElementById('measurementTime').value = new Date().toLocaleTimeString('en-US', { hour12: false, hour: '2-digit', minute: '2-digit' });
            });

            function collectFormData() {
                const sys2 = parseInt(document.getElementById('measurement2Sys').value);
                const dia2 = parseInt(document.getElementById('measurement2Dia').value);
                const sys3 = parseInt(document.getElementById('measurement3Sys').value);
                const dia3 = parseInt(document.getElementById('measurement3Dia').value);
                
                const avgSys = Math.round((sys2 + sys3) / 2);
                const avgDia = Math.round((dia2 + dia3) / 2);

                return {
                    patientId: document.getElementById('patientId').value,
                    patientAge: parseInt(document.getElementById('patientAge').value),
                    patientGender: document.getElementById('patientGender').value,
                    measurementDate: document.getElementById('measurementDate').value,
                    measurementTime: document.getElementById('measurementTime').value,
                    referralSource: document.getElementById('referralSource').value,
                    measurement1Sys: parseInt(document.getElementById('measurement1Sys').value) || null,
                    measurement1Dia: parseInt(document.getElementById('measurement1Dia').value) || null,
                    measurement2Sys: sys2,
                    measurement2Dia: dia2,
                    measurement3Sys: sys3,
                    measurement3Dia: dia3,
                    averageSys: avgSys,
                    averageDia: avgDia,
                    equipment: document.getElementById('equipment').value,
                    cuffSize: document.getElementById('cuffSize').value,
                    armUsed: document.getElementById('armUsed').value,
                    notes: document.getElementById('notes').value
                };
            }

            function validateFormData(data) {
                const required = ['patientId', 'patientAge', 'patientGender', 'measurementDate', 
                                'referralSource', 'measurement2Sys', 'measurement2Dia', 
                                'measurement3Sys', 'measurement3Dia', 'armUsed'];
                
                for (const field of required) {
                    if (!data[field]) {
                        showAlert(`Mangler påkrevd felt: ${field}`, 'error');
                        return false;
                    }
                }

                // Validate blood pressure values
                if (data.measurement2Sys < 70 || data.measurement2Sys > 250 ||
                    data.measurement3Sys < 70 || data.measurement3Sys > 250) {
                    showAlert('Systolisk blodtrykk må være mellom 70 og 250 mmHg', 'error');
                    return false;
                }

                if (data.measurement2Dia < 40 || data.measurement2Dia > 150 ||
                    data.measurement3Dia < 40 || data.measurement3Dia > 150) {
                    showAlert('Diastolisk blodtrykk må være mellom 40 og 150 mmHg', 'error');
                    return false;
                }

                return true;
            }

            // Contact form
            document.getElementById('contactForm').addEventListener('submit', function(e) {
                e.preventDefault();
                showAlert('Takk for din henvendelse! Vi vil kontakte deg så snart som mulig.');
                this.reset();
            });

            // Export functionality
            document.getElementById('exportDataBtn').addEventListener('click', function() {
                const format = document.getElementById('exportFormat').value;
                const fromDate = document.getElementById('exportFromDate').value;
                const toDate = document.getElementById('exportToDate').value;

                let filteredRecords = bpRecords;

                // Apply date filters
                if (fromDate) {
                    filteredRecords = filteredRecords.filter(record => 
                        record.measurementDate >= fromDate);
                }
                if (toDate) {
                    filteredRecords = filteredRecords.filter(record => 
                        record.measurementDate <= toDate);
                }

                if (filteredRecords.length === 0) {
                    showAlert('Ingen registreringer funnet for valgt periode', 'warning');
                    return;
                }

                // Simulate export
                showAlert(`Eksporterer ${filteredRecords.length} registreringer som ${format.toUpperCase()}`);
                
                // In a real application, you would generate and download the file here
                setTimeout(() => {
                    showAlert('Eksport fullført! Filen lastes ned...', 'success');
                }, 1000);
            });

            // Statistics
            function updateStatistics() {
                if (bpRecords.length === 0) {
                    generateSampleData();
                }

                const statsCards = document.getElementById('statsCards');
                const recentTable = document.querySelector('#recentMeasurements tbody');
                
                // Calculate statistics
                const totalMeasurements = bpRecords.length;
                const today = new Date().toISOString().split('T')[0];
                const todayMeasurements = bpRecords.filter(r => r.measurementDate === today).length;
                
                const categories = {};
                bpRecords.forEach(record => {
                    const category = categorizeBP(record.averageSys, record.averageDia);
                    categories[category.key] = (categories[category.key] || 0) + 1;
                });

                const highBPCount = (categories.high || 0) + (categories.veryHigh || 0);
                const highBPPercentage = totalMeasurements > 0 ? Math.round((highBPCount / totalMeasurements) * 100) : 0;

                const avgAge = totalMeasurements > 0 ? 
                    Math.round(bpRecords.reduce((sum, r) => sum + r.patientAge, 0) / totalMeasurements) : 0;

                // Update stats cards
                statsCards.innerHTML = `
                    <div class="stats-card">
                        <span class="stats-number">${totalMeasurements}</span>
                        <span class="stats-label">Totale målinger</span>
                    </div>
                    <div class="stats-card">
                        <span class="stats-number">${todayMeasurements}</span>
                        <span class="stats-label">Målinger i dag</span>
                    </div>
                    <div class="stats-card">
                        <span class="stats-number">${highBPPercentage}%</span>
                        <span class="stats-label">Forhøyet blodtrykk</span>
                    </div>
                    <div class="stats-card">
                        <span class="stats-number">${avgAge} år</span>
                        <span class="stats-label">Gjennomsnittsalder</span>
                    </div>
                `;

                // Update recent measurements table
                const recentRecords = bpRecords.slice(-10).reverse();
                recentTable.innerHTML = recentRecords.map(record => {
                    const category = categorizeBP(record.averageSys, record.averageDia);
                    const referralLabels = {
                        'maja': 'Maja.no',
                        'self': 'Eget initiativ',
                        'doctor': 'Lege',
                        'other': 'Annet'
                    };
                    
                    return `
                        <tr>
                            <td>${formatDate(record.measurementDate)}</td>
                            <td>${record.patientId}</td>
                            <td>${record.patientAge}</td>
                            <td>${record.averageSys}/${record.averageDia}</td>
                            <td><span class="pressure-status ${category.class}">${category.label}</span></td>
                            <td>${referralLabels[record.referralSource] || record.referralSource}</td>
                        </tr>
                    `;
                }).join('');
            }

            // Admin: Load records table
            function loadRecordsTable() {
                const tbody = document.querySelector('#recordsTable tbody');
                const loader = document.getElementById('recordsLoader');
                
                loader.style.display = 'block';
                
                setTimeout(() => {
                    loader.style.display = 'none';
                    displayRecords(bpRecords);
                }, 500);
            }

            function displayRecords(records) {
                const tbody = document.querySelector('#recordsTable tbody');
                
                if (records.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="7">Ingen registreringer funnet</td></tr>';
                    return;
                }

                tbody.innerHTML = records.map(record => {
                    const category = categorizeBP(record.averageSys, record.averageDia);
                    const referralLabels = {
                        'maja': 'Maja.no',
                        'self': 'Eget initiativ', 
                        'doctor': 'Lege',
                        'other': 'Annet'
                    };

                    return `
                        <tr>
                            <td>${formatDate(record.measurementDate)} ${formatTime(record.measurementTime)}</td>
                            <td>${record.patientId}</td>
                            <td>${record.patientAge}</td>
                            <td>${record.averageSys}/${record.averageDia}</td>
                            <td><span class="pressure-status ${category.class}">${category.label}</span></td>
                            <td>${referralLabels[record.referralSource] || record.referralSource}</td>
                            <td>
                                <button class="btn btn-secondary" onclick="viewRecord('${record.id}')">Vis</button>
                                <button class="btn btn-danger" onclick="deleteRecord('${record.id}')">Slett</button>
                            </td>
                        </tr>
                    `;
                }).join('');
            }

            // Search functionality
            document.getElementById('searchRecordsBtn').addEventListener('click', function() {
                const searchTerm = document.getElementById('searchRecords').value.toLowerCase();
                
                if (!searchTerm) {
                    displayRecords(bpRecords);
                    return;
                }

                const filteredRecords = bpRecords.filter(record => 
                    record.patientId.toLowerCase().includes(searchTerm) ||
                    record.measurementDate.includes(searchTerm)
                );

                displayRecords(filteredRecords);
            });

            // Global functions for record actions
            window.viewRecord = function(recordId) {
                const record = bpRecords.find(r => r.id === recordId);
                if (!record) {
                    showAlert('Registrering ikke funnet', 'error');
                    return;
                }
                alert(`Detaljer for registrering ${record.patientId}\n` +
                      `Blodtrykk: ${record.averageSys}/${record.averageDia} mmHg\n` +
                      `Dato: ${formatDate(record.measurementDate)}\n` +
                      `Kilde: ${record.referralSource}`);
            };

            window.deleteRecord = function(recordId) {
                if (confirm('Er du sikker på at du vil slette denne registreringen?')) {
                    const index = bpRecords.findIndex(r => r.id === recordId);
                    if (index !== -1) {
                        bpRecords.splice(index, 1);
                        showAlert('Registrering slettet');
                        loadRecordsTable();
                    }
                }
            };

            // Generate sample data
            function generateSampleData() {
                const sampleData = [
                    { patientId: 'P001', age: 45, gender: 'male', sys: 135, dia: 88, source: 'maja' },
                    { patientId: 'P002', age: 62, gender: 'female', sys: 165, dia: 95, source: 'self' },
                    { patientId: 'P003', age: 38, gender: 'male', sys: 125, dia: 80, source: 'maja' },
                    { patientId: 'P004', age: 55, gender: 'female', sys: 145, dia: 92, source: 'doctor' },
                    { patientId: 'P005', age: 71, gender: 'male', sys: 155, dia: 98, source: 'self' },
                    { patientId: 'P006', age: 29, gender: 'female', sys: 115, dia: 75, source: 'maja' },
                    { patientId: 'P007', age: 48, gender: 'male', sys: 140, dia: 90, source: 'self' },
                    { patientId: 'P008', age: 66, gender: 'female', sys: 170, dia: 105, source: 'doctor' }
                ];

                sampleData.forEach((data, i) => {
                    const date = new Date();
                    date.setDate(date.getDate() - i);
                    
                    bpRecords.push({
                        id: generateUniqueId(),
                        patientId: data.patientId,
                        patientAge: data.age,
                        patientGender: data.gender,
                        measurementDate: date.toISOString().split('T')[0],
                        measurementTime: '10:00',
                        referralSource: data.source,
                        measurement1Sys: null,
                        measurement1Dia: null,
                        measurement2Sys: data.sys + Math.floor(Math.random() * 10) - 5,
                        measurement2Dia: data.dia + Math.floor(Math.random() * 6) - 3,
                        measurement3Sys: data.sys + Math.floor(Math.random() * 10) - 5,
                        measurement3Dia: data.dia + Math.floor(Math.random() * 6) - 3,
                        averageSys: data.sys,
                        averageDia: data.dia,
                        equipment: 'microlife-b2',
                        cuffSize: 'M/L',
                        armUsed: 'left',
                        notes: '',
                        registeredAt: date.toISOString(),
                        registeredBy: 'Demo'
                    });
                });
            }

            // Initialize
            generateSampleData();
            updateStatistics();
        });