import jalshakti from '../assets/MinistryofJalshakthi.png';
import cwc from '../assets/Cwclogo.jpg';
import cgwb from '../assets/cgwb.jpg';
import fsd from '../assets/fsd.jpeg';
import iaec from '../assets/iaec.jpeg'
import imd from '../assets/imd.jpg';
import ndma from '../assets/ndma.jpeg';
import ndrf from '../assets/ndrf.jpeg';
import nrara from '../assets/nrara.png';
import nwda from '../assets/nwda.jpeg';
import sdma from '../assets/sdma.jpeg';
import indiannavy from '../assets/in.jpg';
const departments = [
  {
    id: 1,
    name: 'Ministry of Jal Shakti',
    image: jalshakti, // Imported Image
    description: 'Responsible for overall water resource management.',
    path: '/ministry-of-jal-shakti'
  },
  {
    id: 2,
    name: 'Central Water Commission',
    image: cwc,
    description: 'Deals with water resources planning, development, and flood control.',
    path: '/central-water-commission'
  },
  {
    id: 3,
    name: 'Central Ground Water Board',
    image: cgwb,
    description: 'Manages groundwater resources and addresses water scarcity issues.',
    path: '/central-ground-water'
  },
  {
    id: 4,
    name: 'Fire Services Department',
    image: fsd,
    description: 'Responsible for fire-fighting and rescue operations, including water-related incidents.',
    path: '/fire-services'
  },
  {
    id: 5,
    name: 'Indian Meteorological Department',
    image: imd,
    description: 'Provides weather forecasts, warnings, and flood alerts.',
    path: '/imd'
  },
  {
    id: 6,
    name: 'Indian Army Engineering Corps',
    image: iaec,
    description: 'Assists in disaster relief, including flood rescue and reconstruction efforts.',
    path: '/indian-army'
  },
  {
    id: 7,
    name: 'National Disaster Management Authority',
    image: ndma,
    description: 'Apex body for disaster management, including water-related disasters.',
    path: '/ndma'
  },
  {
    id: 8,
    name: 'National Disaster Response Force',
    image: ndrf,
    description: 'Specialized force for disaster response and rescue, including floods.',
    path: '/ndrf'
  },
  {
    id: 9,
    name: 'National Search And Rescue Agency',
    image: nrara,
    description: 'Specialized agency for search and rescue operations during disasters.',
    path: '/nsra'
  },
  {
    id: 10,
    name: 'National Water Development Agency',
    image: nwda,
    description: 'Plans and develops national water resources, including river interlinking.',
    path: '/nwda'
  },
  {
    id: 11,
    name: 'State Disaster Management Authorities',
    image: sdma,
    description: 'State-level bodies for disaster coordination and management.',
    path: '/sdma'
  },
  {
    id: 12,
    name: 'Indian Navy',
    image: indiannavy,
    description: 'Assists in maritime rescue operations during disasters and emergencies.',
    path: '/indian-navy'
  },
];

export default departments;
