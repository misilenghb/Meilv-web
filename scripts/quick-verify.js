const { createClient } = require('@supabase/supabase-js');
require('dotenv').config({ path: '.env.local' });

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

const supabase = createClient(supabaseUrl, supabaseServiceKey);

async function quickVerify() {
  console.log('🔍 Quick database verification...\n');

  const tables = ['users', 'guide_applications', 'guides'];
  let allGood = true;

  for (const table of tables) {
    try {
      const { data, error } = await supabase
        .from(table)
        .select('*')
        .limit(1);

      if (error) {
        console.log(`❌ ${table}: ${error.message}`);
        allGood = false;
      } else {
        console.log(`✅ ${table}: OK`);
      }
    } catch (err) {
      console.log(`❌ ${table}: ${err.message}`);
      allGood = false;
    }
  }

  if (allGood) {
    console.log('\n🎉 All tables exist and accessible!');
    console.log('\nYou can now:');
    console.log('1. Start the app: npm run dev');
    console.log('2. Test registration: http://localhost:3001/register');
    console.log('3. Test guide application: http://localhost:3001/apply-guide');
  } else {
    console.log('\n❌ Some tables are missing.');
    console.log('\nPlease:');
    console.log('1. Go to: https://fauzguzoamyahhcqhvoc.supabase.co/project/fauzguzoamyahhcqhvoc/sql');
    console.log('2. Copy the SQL from SETUP-INSTRUCTIONS.md');
    console.log('3. Paste and run in SQL editor');
    console.log('4. Run this script again');
  }

  return allGood;
}

quickVerify().then(success => {
  process.exit(success ? 0 : 1);
}).catch(error => {
  console.error('❌ Verification failed:', error.message);
  process.exit(1);
});
