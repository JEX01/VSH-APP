const bcrypt = require('bcryptjs');

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> } 
 */
exports.seed = async function(knex) {
  // Deletes ALL existing entries
  await knex('users').del();
  
  // Hash passwords
  const saltRounds = 12;
  const adminPassword = await bcrypt.hash('admin123', saltRounds);
  const managerPassword = await bcrypt.hash('manager123', saltRounds);
  const workerPassword = await bcrypt.hash('worker123', saltRounds);
  
  // Inserts seed entries
  await knex('users').insert([
    {
      id: '550e8400-e29b-41d4-a716-446655440010',
      username: 'admin',
      email: 'admin@ntpc.co.in',
      password_hash: adminPassword,
      first_name: 'System',
      last_name: 'Administrator',
      role: 'admin',
      employee_id: 'NTPC-ADM-001',
      department: 'IT',
      plant_area: null, // Admin has access to all areas
      phone: '+91-9876543200',
      is_active: true,
      email_verified: true,
      created_at: new Date(),
      updated_at: new Date()
    },
    {
      id: '550e8400-e29b-41d4-a716-446655440011',
      username: 'manager1',
      email: 'manager1@ntpc.co.in',
      password_hash: managerPassword,
      first_name: 'Amit',
      last_name: 'Singh',
      role: 'manager',
      employee_id: 'NTPC-MGR-001',
      department: 'Operations',
      plant_area: 'Boiler Area',
      phone: '+91-9876543201',
      is_active: true,
      email_verified: true,
      created_at: new Date(),
      updated_at: new Date()
    },
    {
      id: '550e8400-e29b-41d4-a716-446655440012',
      username: 'manager2',
      email: 'manager2@ntpc.co.in',
      password_hash: managerPassword,
      first_name: 'Sunita',
      last_name: 'Patel',
      role: 'manager',
      employee_id: 'NTPC-MGR-002',
      department: 'Maintenance',
      plant_area: 'Turbine Area',
      phone: '+91-9876543202',
      is_active: true,
      email_verified: true,
      created_at: new Date(),
      updated_at: new Date()
    },
    {
      id: '550e8400-e29b-41d4-a716-446655440013',
      username: 'worker1',
      email: 'worker1@ntpc.co.in',
      password_hash: workerPassword,
      first_name: 'Ramesh',
      last_name: 'Yadav',
      role: 'worker',
      employee_id: 'NTPC-WRK-001',
      department: 'Operations',
      plant_area: 'Boiler Area',
      phone: '+91-9876543203',
      is_active: true,
      email_verified: true,
      created_at: new Date(),
      updated_at: new Date()
    },
    {
      id: '550e8400-e29b-41d4-a716-446655440014',
      username: 'worker2',
      email: 'worker2@ntpc.co.in',
      password_hash: workerPassword,
      first_name: 'Kavita',
      last_name: 'Devi',
      role: 'worker',
      employee_id: 'NTPC-WRK-002',
      department: 'Maintenance',
      plant_area: 'Turbine Area',
      phone: '+91-9876543204',
      is_active: true,
      email_verified: true,
      created_at: new Date(),
      updated_at: new Date()
    },
    {
      id: '550e8400-e29b-41d4-a716-446655440015',
      username: 'worker3',
      email: 'worker3@ntpc.co.in',
      password_hash: workerPassword,
      first_name: 'Suresh',
      last_name: 'Kumar',
      role: 'worker',
      employee_id: 'NTPC-WRK-003',
      department: 'Operations',
      plant_area: 'Generator Area',
      phone: '+91-9876543205',
      is_active: true,
      email_verified: true,
      created_at: new Date(),
      updated_at: new Date()
    }
  ]);
};