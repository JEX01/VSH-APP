/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> } 
 */
exports.seed = async function(knex) {
  // Deletes ALL existing entries
  await knex('plants').del();
  
  // Inserts seed entries
  await knex('plants').insert([
    {
      id: '550e8400-e29b-41d4-a716-446655440001',
      plant_code: 'NTPC-A',
      plant_name: 'NTPC Plant A - Thermal Power Station',
      description: 'Main thermal power generation facility with 4 units',
      location: 'Singrauli, Madhya Pradesh',
      latitude: 24.1993,
      longitude: 82.6739,
      contact_person: 'Rajesh Kumar',
      contact_phone: '+91-9876543210',
      contact_email: 'rajesh.kumar@ntpc.co.in',
      is_active: true,
      created_at: new Date(),
      updated_at: new Date()
    },
    {
      id: '550e8400-e29b-41d4-a716-446655440002',
      plant_code: 'NTPC-B',
      plant_name: 'NTPC Plant B - Hydro Power Station',
      description: 'Hydroelectric power generation facility',
      location: 'Tehri, Uttarakhand',
      latitude: 30.3753,
      longitude: 78.4804,
      contact_person: 'Priya Sharma',
      contact_phone: '+91-9876543211',
      contact_email: 'priya.sharma@ntpc.co.in',
      is_active: true,
      created_at: new Date(),
      updated_at: new Date()
    }
  ]);
};