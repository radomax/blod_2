import { json } from '@sveltejs/kit';

// Mock database connection
let mockRecords = [];

export async function GET({ url }) {
    const action = url.searchParams.get('action');
    const limit = parseInt(url.searchParams.get('limit') || '100');
    const offset = parseInt(url.searchParams.get('offset') || '0');
    const search = url.searchParams.get('search') || '';

    try {
        switch (action) {
            case 'list':
                let filteredRecords = mockRecords;
                
                if (search) {
                    filteredRecords = mockRecords.filter(record =>
                        record.patientId.toLowerCase().includes(search.toLowerCase()) ||
                        record.measurementDate.includes(search)
                    );
                }
                
                const paginatedRecords = filteredRecords
                    .slice(offset, offset + limit)
                    .sort((a, b) => new Date(b.registeredAt) - new Date(a.registeredAt));

                return json({
                    success: true,
                    data: paginatedRecords
                });

            case 'statistics':
                const total = mockRecords.length;
                const today = new Date().toISOString().split('T')[0];
                const todayCount = mockRecords.filter(r => r.measurementDate === today).length;
                const highBPCount = mockRecords.filter(r => r.averageSys >= 140 || r.averageDia >= 90).length;
                const avgAge = total > 0 ? 
                    Math.round(mockRecords.reduce((sum, r) => sum + (r.patientAge || 0), 0) / total) : 0;

                return json({
                    success: true,
                    data: {
                        total,
                        today: todayCount,
                        highBP: highBPCount,
                        avgAge
                    }
                });

            default:
                return json({
                    success: false,
                    message: 'Invalid action'
                }, { status: 400 });
        }
    } catch (error) {
        console.error('API Error:', error);
        return json({
            success: false,
            message: error.message
        }, { status: 500 });
    }
}

export async function POST({ request }) {
    try {
        const { action, data, id } = await request.json();

        switch (action) {
            case 'save':
                const newRecord = {
                    id: Math.random().toString(36).substr(2, 9),
                    ...data,
                    registeredAt: new Date().toISOString(),
                    registeredBy: 'System'
                };
                
                mockRecords.unshift(newRecord);
                
                return json({
                    success: true,
                    message: 'Measurement saved successfully',
                    data: { id: newRecord.id }
                });

            default:
                return json({
                    success: false,
                    message: 'Invalid action'
                }, { status: 400 });
        }
    } catch (error) {
        console.error('API Error:', error);
        return json({
            success: false,
            message: error.message
        }, { status: 500 });
    }
}

export async function DELETE({ request }) {
    try {
        const { id } = await request.json();
        
        const index = mockRecords.findIndex(r => r.id === id);
        if (index === -1) {
            return json({
                success: false,
                message: 'Record not found'
            }, { status: 404 });
        }
        
        mockRecords.splice(index, 1);
        
        return json({
            success: true,
            message: 'Record deleted successfully'
        });
    } catch (error) {
        console.error('API Error:', error);
        return json({
            success: false,
            message: error.message
        }, { status: 500 });
    }
}