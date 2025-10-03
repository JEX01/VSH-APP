/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.up = function(knex) {
  return knex.schema.createTable('photos', function(table) {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('user_id').notNullable().references('id').inTable('users').onDelete('CASCADE');
    table.uuid('equipment_id').notNullable().references('id').inTable('equipment').onDelete('CASCADE');
    table.string('filename', 255).notNullable();
    table.string('original_filename', 255);
    table.string('s3_key', 500).notNullable(); // S3 object key
    table.string('thumbnail_s3_key', 500); // Thumbnail S3 object key
    table.string('mime_type', 100).notNullable();
    table.integer('file_size').notNullable(); // in bytes
    table.integer('width');
    table.integer('height');
    table.decimal('latitude', 10, 8);
    table.decimal('longitude', 11, 8);
    table.decimal('gps_accuracy', 8, 2); // GPS accuracy in meters
    table.timestamp('captured_at').notNullable();
    table.string('device_info', 255);
    table.text('notes');
    table.enum('status', ['pending', 'approved', 'rejected', 'deleted']).notNullable().defaultTo('pending');
    table.string('rejection_reason', 500);
    table.uuid('approved_by').references('id').inTable('users');
    table.timestamp('approved_at');
    table.json('metadata').defaultTo('{}'); // EXIF data, etc.
    table.string('checksum', 64); // SHA-256 checksum for integrity
    table.timestamps(true, true);
    
    // Indexes
    table.index(['user_id']);
    table.index(['equipment_id']);
    table.index(['status']);
    table.index(['captured_at']);
    table.index(['approved_by']);
    table.index(['created_at']);
  });
};

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.down = function(knex) {
  return knex.schema.dropTable('photos');
};