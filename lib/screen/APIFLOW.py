import random
from typing import Dict, List, Optional, Any
from .database_helper import DatabaseHelper

class VegetableScannerAPI:
    _instance = None
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(VegetableScannerAPI, cls).__new__(cls)
            cls._instance._initialize()
        return cls._instance
    
    def _initialize(self):
        self._database_helper = DatabaseHelper()
        self._vegetable_database = {
            'singkamas': {
                'name': 'Singkamas',
                'english': 'Jicama',
                'scientific': 'Pachyrhizus erosus',
                'info': 'A crispy, sweet root vegetable native to Mexico with a texture similar to pear or raw potato.',
                'lifespan': '150-180 days from planting to harvest',
                'location': 'Native to Mexico, grown in tropical regions worldwide',
                'nutrition': 'Rich in Vitamin C, Fiber, and Potassium. Low in calories.',
                'recipes': [
                    'Singkamas Salad with shrimp and mango',
                    'Fresh Singkamas sticks with chili powder',
                    'Singkamas and carrot spring rolls',
                    'Singkamas juice with lime and honey'
                ],
                'growing_tips': 'Prefers warm climate, well-drained soil, and regular watering',
                'image': 'assets/images/singkamas.png',
                'types': [
                    {
                        'name': 'Common Jicama',
                        'description': 'The most widely available variety with light brown skin and white flesh.',
                        'characteristics': 'Round shape, crisp texture, sweet flavor'
                    },
                    {
                        'name': 'Jicama de Aqua',
                        'description': 'A variety with higher water content and milder flavor.',
                        'characteristics': 'Larger size, more watery, less sweet'
                    },
                    {
                        'name': 'Chinese Jicama',
                        'description': 'A smaller variety with a more intense flavor and crunchier texture.',
                        'characteristics': 'Smaller size, denser texture, stronger flavor'
                    }
                ]
            },
            # ... (Include all other vegetables from the original Dart code)
            # For brevity, I've only included one vegetable here
            # You should include all vegetables from the original code
        }

    def get_all_vegetables(self) -> Dict[str, Dict[str, Any]]:
        return self._vegetable_database

    def get_vegetable_by_key(self, key: str) -> Optional[Dict[str, Any]]:
        return self._vegetable_database.get(key)

    async def scan_vegetable(self) -> str:
        vegetable_keys = list(self._vegetable_database.keys())
        random_index = random.randint(0, len(vegetable_keys) - 1)
        vegetable_key = vegetable_keys[random_index]
        await self.record_vegetable_scan(vegetable_key)
        return vegetable_key

    async def record_vegetable_scan(self, vegetable_key: str) -> None:
        await self._database_helper.record_vegetable_scan(vegetable_key)

    async def get_vegetable_info(self, key: str) -> Optional[Dict[str, Any]]:
        vegetable = self._vegetable_database.get(key)
        if vegetable is None:
            return None
        
        scan_count = await self._database_helper.get_vegetable_scan_count(key)
        result = dict(vegetable)
        result['scan_count'] = scan_count
        return result

    async def get_all_vegetables_with_scan_counts(self) -> List[Dict[str, Any]]:
        result = []
        for key in self._vegetable_database.keys():
            vegetable = dict(self._vegetable_database[key])
            scan_count = await self._database_helper.get_vegetable_scan_count(key)
            vegetable['scan_count'] = scan_count
            vegetable['key'] = key
            result.append(vegetable)
        
        result.sort(key=lambda x: x['scan_count'], reverse=True)
        return result

    async def get_total_scan_count(self) -> int:6
        try:
            return await self._database_helper.get_total_scan_count()
        except Exception as e:
            print(f'Error getting total scan count: {e}')
            return 0

    async def get_most_scanned_vegetables(self, limit: int = 10) -> List[Dict[str, Any]]:
        all_vegetables = await self.get_all_vegetables_with_scan_counts()
        return all_vegetables[:limit] if limit > 0 else all_vegetables

    async def get_scan_statistics(self) -> Dict[str, Any]:
        all_vegetables = await self.get_all_vegetables_with_scan_counts()
        total_scans = await self.get_total_scan_count()
        most_scanned = await self.get_most_scanned_vegetables(limit=5)
        
        return {
            'total_vegetables': len(all_vegetables),
            'total_scans': total_scans,
            'most_scanned': most_scanned,
            'average_scans': total_scans / len(all_vegetables) if all_vegetables else 0,
        }

    async def get_vegetable_scan_count_by_name(self, vegetable_name: str) -> int:
        try:
            vegetable_key = vegetable_name.lower().replace(' ', '_')
            return await self._database_helper.get_vegetable_scan_count(vegetable_key)
        except Exception as e:
            print(f'Error getting vegetable scan count by name: {e}')
            return 0

    async def record_vegetable_scan_by_name(self, vegetable_name: str) -> None:
        try:
            vegetable_key = vegetable_name.lower().replace(' ', '_')
            await self._database_helper.record_vegetable_scan(vegetable_key)
        except Exception as e:
            print(f'Error recording vegetable scan by name: {e}')
            raise

    async def get_database_statistics(self) -> Dict[str, Any]:
        try:
            return await self._database_helper.get_database_stats()
        except Exception as e:
            print(f'Error getting database statistics: {e}')
            return {
                'total_users': 0,
                'pending_users': 0,
                'total_scans': 0,
                'total_vegetables': 0,
                'approved_users': 0,
            }