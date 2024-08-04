/**
 * Write file
 */
import Database from 'better-sqlite3';

const callDB = () => {
  const db = new Database('/mnt/efs/metrics.db');
  db.pragma('journal_mode = WAL');

  db.prepare("create table if not exists metrics (testText TEXT, testInt INTEGER)").run();

  const NUM_INSERTS = process.env.NUM_INSERTS || 100;
  const insertStm = db.prepare('INSERT INTO metrics (testText, testInt) VALUES (?, ?)');
  db.transaction(
    () => {
      for (let i=0; i<NUM_INSERTS; i++) {
        if (Math.random() < 0.6) {
          insertStm.run(`metricsTest-${i}`, i);
        } else {
          insertStm.run(`metricsTest`, i);
        }
      }
    }
  )();
  console.log(`finished ${NUM_INSERTS} inserts`);

  const row = db.prepare('SELECT * FROM metrics WHERE testText LIKE ?').get(`metricsTest`);
  console.log(row.name, row.age);
  console.log(`finished single where`);

  const rows = db.prepare('SELECT * FROM metrics WHERE testText LIKE ?').all(`metricsTest%`);
  console.log(`finished fetching ${rows.length} rows`);

  db.close();
}

export const handler = async (event) => {
  console.log(`event: `, event);
  callDB();

  const response = {
    statusCode: 200,
    body: JSON.stringify('Check1'),
  };
  return response;
};
