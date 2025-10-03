/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.up = function(knex) {
  return knex.schema.createTable('equipment', function(table) {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('plant_id').notNullable().references('id').inTable('plants').onDelete('CASCADE');
    table.string('equipment_code', 50).notNullable();
    table.string('equipment_name', 255).notNullable();
    table.string('equipment_type', 100); // Boiler, Turbine, Generator, etc.
    table.text('description');
    table.string('manufacturer', 100);
    table.string('model', 100);
    table.string('serial_number', 100);
    table.date('installation_date');
    table.string('location_area', 100);
    table.decimal('latitude', 10, 8);
    table.decimal('longitude', 11, 8);
    table.string('qr_code', 255).unique(); // QR code for scanning
    table.json('specifications').defaultTo('{}');
    table.enum('status', ['active', 'maintenance', 'inactive']).notNullable().defaultTo('active');
    table.timestamps(true, true);
    
    // Composite unique constraint
    table.unique(['plant_id', 'equipment_code']);
    
    // Indexes
    table.index(['plant_id']);
    table.index(['equipment_type']);
    table.index(['status']);
    table.index(['qr_code']);
    table.index(['location_area']);
  });
};

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.down = function(knex) {
  return knex.schema.dropTable('equipment');
};