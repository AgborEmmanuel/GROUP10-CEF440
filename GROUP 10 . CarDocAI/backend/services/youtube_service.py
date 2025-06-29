from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
import os
import logging
from typing import List, Dict, Any, Optional
import asyncio

logger = logging.getLogger(__name__)

class YouTubeService:
    def __init__(self):
        self.api_key = os.getenv("YOUTUBE_API_KEY")
        if not self.api_key:
            raise ValueError("YOUTUBE_API_KEY environment variable is required")
        
        self.youtube = build('youtube', 'v3', developerKey=self.api_key)
        logger.info("✅ YouTube API service initialized")
        
        # Search parameters
        self.max_results = 8
        self.default_order = 'relevance'
        self.video_duration = 'medium'  # 4-20 minutes
        self.video_definition = 'any'
        
    async def search_tutorials(self, keywords: List[str], max_results: int = 5) -> List[Dict[str, Any]]:
        """
        Search for car repair tutorials using specific fault-based keywords
        """
        try:
            # Use the most specific keywords first
            search_queries = []
            
            # Create multiple search queries for better results
            for keyword in keywords[:3]:  # Use top 3 keywords
                # Add car repair context to each keyword
                enhanced_query = f"{keyword} car repair tutorial how to fix"
                search_queries.append(enhanced_query)
            
            all_tutorials = []
            
            # Search with each query
            for query in search_queries:
                tutorials = await self._search_with_query(query, max_results // len(search_queries) + 1)
                all_tutorials.extend(tutorials)
            
            # Remove duplicates and rank
            unique_tutorials = self._remove_duplicates(all_tutorials)
            ranked_tutorials = await self._rank_tutorials_by_relevance(unique_tutorials, keywords)
            
            # Return top results
            final_tutorials = ranked_tutorials[:max_results]
            
            logger.info(f"✅ Found {len(final_tutorials)} relevant YouTube tutorials")
            return final_tutorials
            
        except Exception as e:
            logger.error(f"Error searching YouTube tutorials: {e}")
            return self._get_enhanced_fallback_tutorials(keywords)
    
    async def _search_with_query(self, query: str, max_results: int) -> List[Dict[str, Any]]:
        """Search YouTube with a specific query"""
        try:
            # Perform YouTube search
            search_response = await asyncio.to_thread(
                self.youtube.search().list,
                q=query,
                part='id,snippet',
                maxResults=max_results,
                order=self.default_order,
                type='video',
                videoDuration=self.video_duration,
                videoDefinition=self.video_definition,
                relevanceLanguage='en',
                safeSearch='moderate'
            )
            
            tutorials = []
            for item in search_response.get('items', []):
                tutorial = await self._process_video_item(item)
                if tutorial and self._is_relevant_tutorial(tutorial):
                    tutorials.append(tutorial)
            
            return tutorials
            
        except HttpError as e:
            logger.error(f"YouTube API HTTP error: {e}")
            return []
        except Exception as e:
            logger.error(f"YouTube search error: {e}")
            return []
    
    async def _process_video_item(self, item: Dict) -> Optional[Dict[str, Any]]:
        """Process individual video item from search results"""
        try:
            video_id = item['id']['videoId']
            snippet = item['snippet']
            
            tutorial = {
                "title": snippet.get('title', ''),
                "url": f"https://www.youtube.com/watch?v={video_id}",
                "thumbnail": snippet.get('thumbnails', {}).get('medium', {}).get('url', ''),
                "channel": snippet.get('channelTitle', ''),
                "description": snippet.get('description', '')[:200] + "..." if snippet.get('description') else '',
                "published_at": snippet.get('publishedAt', ''),
                "video_id": video_id,
                "relevance_score": 0.0
            }
            
            return tutorial
            
        except Exception as e:
            logger.error(f"Error processing video item: {e}")
            return None
    
    def _is_relevant_tutorial(self, tutorial: Dict[str, Any]) -> bool:
        """Check if tutorial is relevant for car repair"""
        title_lower = tutorial["title"].lower()
        description_lower = tutorial["description"].lower()
        
        # Positive indicators
        positive_keywords = [
            "repair", "fix", "how to", "tutorial", "diy", "maintenance",
            "car", "auto", "vehicle", "engine", "dashboard", "warning",
            "brake", "oil", "fluid", "light", "replace", "install"
        ]
        
        # Negative indicators (filter out)
        negative_keywords = [
            "music", "song", "game", "movie", "trailer", "review only",
            "unboxing", "shopping", "buy", "sale", "price", "commercial"
        ]
        
        # Check for negative keywords
        for neg_keyword in negative_keywords:
            if neg_keyword in title_lower or neg_keyword in description_lower:
                return False
        
        # Check for positive keywords
        positive_count = 0
        for pos_keyword in positive_keywords:
            if pos_keyword in title_lower:
                positive_count += 2
            if pos_keyword in description_lower:
                positive_count += 1
        
        return positive_count >= 2  # Require at least 2 positive indicators
    
    async def _rank_tutorials_by_relevance(self, tutorials: List[Dict], keywords: List[str]) -> List[Dict]:
        """Rank tutorials by relevance to the specific fault"""
        try:
            # Get additional video details for ranking
            if tutorials:
                tutorials = await self._enrich_video_details(tutorials)
            
            for tutorial in tutorials:
                score = 0
                title_lower = tutorial["title"].lower()
                description_lower = tutorial["description"].lower()
                
                # Score based on keyword matches in title (highest weight)
                for keyword in keywords:
                    keyword_lower = keyword.lower()
                    if keyword_lower in title_lower:
                        score += 10
                    if keyword_lower in description_lower:
                        score += 3
                
                # Score based on video quality indicators
                view_count = tutorial.get("view_count", 0)
                if view_count > 50000:
                    score += 5
                elif view_count > 10000:
                    score += 3
                elif view_count > 1000:
                    score += 1
                
                # Score based on engagement
                like_count = tutorial.get("like_count", 0)
                if like_count > 500:
                    score += 3
                elif like_count > 100:
                    score += 2
                elif like_count > 50:
                    score += 1
                
                # Score based on duration (prefer 5-20 minute videos)
                duration_minutes = tutorial.get("duration_minutes", 0)
                if 5 <= duration_minutes <= 20:
                    score += 3
                elif 3 <= duration_minutes <= 30:
                    score += 1
                
                # Score based on channel credibility
                channel_lower = tutorial.get("channel", "").lower()
                credible_indicators = [
                    "garage", "mechanic", "auto", "car", "repair", "fix",
                    "official", "certified", "expert", "pro", "master"
                ]
                for indicator in credible_indicators:
                    if indicator in channel_lower:
                        score += 2
                        break
                
                tutorial["relevance_score"] = score
            
            # Sort by relevance score
            tutorials.sort(key=lambda x: x.get("relevance_score", 0), reverse=True)
            
            return tutorials
            
        except Exception as e:
            logger.error(f"Error ranking tutorials: {e}")
            return tutorials
    
    async def _enrich_video_details(self, tutorials: List[Dict]) -> List[Dict]:
        """Get additional video details for better ranking"""
        try:
            if not tutorials:
                return tutorials
            
            # Get video IDs
            video_ids = [tutorial["video_id"] for tutorial in tutorials if "video_id" in tutorial]
            
            if not video_ids:
                return tutorials
            
            # Batch request for video details
            videos_response = await asyncio.to_thread(
                self.youtube.videos().list,
                part='contentDetails,statistics',
                id=','.join(video_ids)
            )
            
            # Create lookup dictionary
            video_details = {}
            for item in videos_response.get('items', []):
                video_id = item['id']
                content_details = item.get('contentDetails', {})
                statistics = item.get('statistics', {})
                
                video_details[video_id] = {
                    "duration": content_details.get('duration', ''),
                    "view_count": int(statistics.get('viewCount', 0)),
                    "like_count": int(statistics.get('likeCount', 0)),
                    "comment_count": int(statistics.get('commentCount', 0))
                }
            
            # Enrich tutorials with additional details
            for tutorial in tutorials:
                video_id = tutorial.get("video_id")
                if video_id and video_id in video_details:
                    tutorial.update(video_details[video_id])
                    
                    # Parse duration to minutes
                    duration_str = tutorial.get("duration", "")
                    tutorial["duration_minutes"] = self._parse_duration(duration_str)
            
            return tutorials
            
        except Exception as e:
            logger.error(f"Error enriching video details: {e}")
            return tutorials
    
    def _parse_duration(self, duration_str: str) -> int:
        """Parse YouTube duration format (PT4M13S) to minutes"""
        try:
            if not duration_str.startswith('PT'):
                return 0
            
            duration_str = duration_str[2:]  # Remove 'PT'
            minutes = 0
            seconds = 0
            
            if 'M' in duration_str:
                parts = duration_str.split('M')
                minutes = int(parts[0])
                duration_str = parts[1] if len(parts) > 1 else ''
            
            if 'S' in duration_str:
                seconds = int(duration_str.replace('S', ''))
            
            return minutes + (seconds // 60)
            
        except Exception:
            return 0
    
    def _remove_duplicates(self, tutorials: List[Dict]) -> List[Dict]:
        """Remove duplicate videos from search results"""
        seen_ids = set()
        unique_tutorials = []
        
        for tutorial in tutorials:
            video_id = tutorial.get("video_id")
            if video_id and video_id not in seen_ids:
                seen_ids.add(video_id)
                unique_tutorials.append(tutorial)
        
        return unique_tutorials
    
    def _get_enhanced_fallback_tutorials(self, keywords: List[str]) -> List[Dict[str, Any]]:
        """Provide enhanced fallback tutorials when API fails"""
        
        # Create search URLs based on keywords
        search_term = "+".join(keywords[:2]).replace(" ", "+")
        
        fallback_tutorials = [
            {
                "title": f"How to Fix {' '.join(keywords[:2])} - Complete Repair Guide",
                "url": f"https://www.youtube.com/results?search_query={search_term}+car+repair+tutorial",
                "thumbnail": "https://img.youtube.com/vi/dQw4w9WgXcQ/mqdefault.jpg",
                "channel": "Auto Repair Pro",
                "description": f"Professional guide for fixing {' '.join(keywords[:2])} in your vehicle...",
                "published_at": "2024-01-01T00:00:00Z",
                "relevance_score": 8,
                "is_fallback": True
            },
            {
                "title": f"{' '.join(keywords[:2])} Diagnosis and Repair Tutorial",
                "url": f"https://www.youtube.com/results?search_query={search_term}+diagnosis+fix",
                "thumbnail": "https://img.youtube.com/vi/dQw4w9WgXcQ/mqdefault.jpg",
                "channel": "Car Mechanic Guide",
                "description": f"Step-by-step diagnosis and repair for {' '.join(keywords[:2])} issues...",
                "published_at": "2024-01-01T00:00:00Z",
                "relevance_score": 7,
                "is_fallback": True
            },
            {
                "title": f"DIY {' '.join(keywords[:1])} Repair - Save Money",
                "url": f"https://www.youtube.com/results?search_query={keywords[0].replace(' ', '+')}+DIY+repair",
                "thumbnail": "https://img.youtube.com/vi/dQw4w9WgXcQ/mqdefault.jpg",
                "channel": "DIY Car Repairs",
                "description": f"Learn to fix {keywords[0]} yourself with this detailed tutorial...",
                "published_at": "2024-01-01T00:00:00Z",
                "relevance_score": 6,
                "is_fallback": True
            }
        ]
        
        return fallback_tutorials

# Global service instance
youtube_service = YouTubeService()
