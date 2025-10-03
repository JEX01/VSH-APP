/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> } 
 */
exports.seed = async function(knex) {
  // Deletes ALL existing entries
  await knex('equipment').del();
  
  // Inserts seed entries
  await knex('equipment').insert([
    {
      id: '550e8400-e29b-41d4-a716-446655440020',
      plant_id: '550e8400-e29b-41d4-a716-446655440001', // NTPC-A
      equipment_code: 'BOILER-001',
      equipment_name: 'Main Boiler Unit 1',
      equipment_type: 'Boiler',
      description: 'Primary steam generation boiler for Unit 1',
      manufacturer: 'BHEL',
      model: 'BH-500MW',
      serial_number: 'BH001-2020-001',
      installation_date: '2020-01-15',
      location_area: 'Boiler Area',
      latitude: 24.1995,
      longitude: 82.6741,
      qr_code: 'QR-BOILER-001',
      specifications: JSON.stringify({
        capacity: '500 MW',
        pressure: '165 bar',
        temperature: '540°C',
        fuel_type: 'Coal'
      }),
      status: 'active',
      created_at: new Date(),
      updated_at: new Date()
    },
    {
      id: '550e8400-e29b-41d4-a716-446655440021',
      plant_id: '550e8400-e29b-41d4-a716-446655440001', // NTPC-A
      equipment_code: 'TURBINE-001',
      equipment_name: 'Steam Turbine Unit 1',
      equipment_type: 'Turbine',
      description: 'High pressure steam turbine for Unit 1',
      manufacturer: 'BHEL',
      model: 'ST-500MW',
      serial_number: 'ST001-2020-001',
      installation_date: '2020-03-20',
      location_area: 'Turbine Area',
      latitude: 24.1997,
      longitude: 82.6743,
      qr_code: 'QR-TURBINE-001',
      specifications: JSON.stringify({
        capacity: '500 MW',
        rpm: '3000',
        stages: '4 HP + 6 IP + 7 LP',
        cooling: 'Water cooled'
      }),
      status: 'active',
      created_at: new Date(),
      updated_at: new Date()
    },
    {
      id: '550e8400-e29b-41d4-a716-446655440022',
      plant_id: '550e8400-e29b-41d4-a716-446655440001', // NTPC-A
      equipment_code: 'GEN-001',
      equipment_name: 'Generator Unit 1',
      equipment_type: 'Generator',
      description: 'Synchronous generator for Unit 1',
      manufacturer: 'BHEL',
      model: 'GEN-500MW',
      serial_number: 'GEN001-2020-001',
      installation_date: '2020-05-10',
      location_area: 'Generator Area',
      latitude: 24.1999,
      longitude: 82.6745,
      qr_code: 'QR-GEN-001',
      specifications: JSON.stringify({
        capacity: '500 MW',
        voltage: '21 kV',
        frequency: '50 Hz',
        power_factor: '0.85'
      }),
      status: 'active',
      created_at: new Date(),
      updated_at: new Date()
    },
    {
      id: '550e8400-e29b-41d4-a716-446655440023',
      plant_id: '550e8400-e29b-41d4-a716-446655440001', // NTPC-A
      equipment_code: 'PUMP-001',
      equipment_name: 'Boiler Feed Pump 1A',
      equipment_type: 'Pump',
      description: 'Primary boiler feed water pump',
      manufacturer: 'KSB',
      model: 'BFP-250',
      serial_number: 'KSB001-2020-001',
      installation_date: '2020-02-28',
      location_area: 'Boiler Area',
      latitude: 24.1994,
      longitude: 82.6740,
      qr_code: 'QR-PUMP-001',
      specifications: JSON.stringify({
        flow_rate: '2500 m³/h',
        head: '180 m',
        power: '5 MW',
        efficiency: '85%'
      }),
      status: 'active',
      created_at: new Date(),
      updated_at: new Date()
    },
    {
      id: '550e8400-e29b-41d4-a716-446655440024',
      plant_id: '550e8400-e29b-41d4-a716-446655440001', // NTPC-A
      equipment_code: 'TRANSFORMER-001',
      equipment_name: 'Main Power Transformer 1',
      equipment_type: 'Transformer',
      description: 'Step-up transformer for Unit 1',
      manufacturer: 'ABB',
      model: 'TXF-500MVA',
      serial_number: 'ABB001-2020-001',
      installation_date: '2020-04-15',
      location_area: 'Switchyard',
      latitude: 24.2001,
      longitude: 82.6747,
      qr_code: 'QR-TRANSFORMER-001',
      specifications: JSON.stringify({
        capacity: '500 MVA',
        voltage_primary: '21 kV',
        voltage_secondary: '400 kV',
        cooling: 'ONAN/ONAF'
      }),
      status: 'active',
      created_at: new Date(),
      updated_at: new Date()
    },
    {
      id: '550e8400-e29b-41d4-a716-446655440025',
      plant_id: '550e8400-e29b-41d4-a716-446655440002', // NTPC-B (Hydro)
      equipment_code: 'HYDRO-TURBINE-001',
      equipment_name: 'Francis Turbine Unit 1',
      equipment_type: 'Hydro Turbine',
      description: 'Francis type hydro turbine for Unit 1',
      manufacturer: 'Andritz',
      model: 'FT-250MW',
      serial_number: 'AND001-2021-001',
      installation_date: '2021-06-20',
      location_area: 'Powerhouse',
      latitude: 30.3755,
      longitude: 78.4806,
      qr_code: 'QR-HYDRO-TURBINE-001',
      specifications: JSON.stringify({
        capacity: '250 MW',
        head: '195 m',
        flow: '140 m³/s',
        efficiency: '94%'
      }),
      status: 'active',
      created_at: new Date(),
      updated_at: new Date()
    }
  ]);
};