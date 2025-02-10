import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Home from './components/Home'; // Create a Home component
import MinistryOfJalShakti from './components/MinistryOfJalShakti';
import CentralWaterCommission from './components/CentralWaterCommission';
import CentralGroundWaterBoard from './components/CentralGroundWaterBoard';
import FireServicesDepartment from './components/FireServicesDepartment';
import IndianMeteorologicalDepartment from './components/IndiaMeteorologicalDepartment';
import IndianArmyEngineeringCorps from './components/IndianArmyEngineeringCorps';
import IndianNavy from './components/IndianNavy';
import NationalDisasterManagementAuthorities from './components/NationalDisasterManagementAuthority';
import NationalDisasterResponseForce from './components/NationalDisasterResponseForce';
import NationalSearchAndRescueAgency from './components/NationalSearchAndRescueAgency';
import NationalWaterDevelopmentAgency from './components/NationalWaterDevelopmentAgency';
import StateDisasterManagementAuthorities from './components/StateDisasterManagementAuthorities';

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Home />} /> {/* Home Page */}
        <Route path="/ministry-of-jal-shakti" element={<MinistryOfJalShakti />} />
        <Route path="/central-water-commission" element={<CentralWaterCommission />} />
        <Route path="/central-ground-water" element={<CentralGroundWaterBoard />} />
        <Route path="/fire-services" element={<FireServicesDepartment />} />
        <Route path="/imd" element={<IndianMeteorologicalDepartment />} />
        <Route path="/indian-army" element={<IndianArmyEngineeringCorps />} />
        <Route path="/indian-navy" element={<IndianNavy />} />
        <Route path="/ndma" element={<NationalDisasterManagementAuthorities />} />
        <Route path="/ndrf" element={<NationalDisasterResponseForce />} />
        <Route path="/nwda" element={<NationalWaterDevelopmentAgency />} />
        <Route path="/nsra" element={<NationalSearchAndRescueAgency />} />
        <Route path="/sdma" element={<StateDisasterManagementAuthorities />} />
      </Routes>
    </Router>
  );
}

export default App;
