import pytest
from decimal import Decimal
from unittest.mock import MagicMock
from app.services.calculator_service import CalculatorService
from app.models.calculator import LivestockAsset, LivestockExpenses, LivestockYield

@pytest.fixture
def db_session_mock():
    return MagicMock()

@pytest.fixture
def calculator_service(db_session_mock):
    service = CalculatorService(db=db_session_mock)
    service.repository = MagicMock()
    return service

def test_get_analytics_summary_net_profit_and_roi(calculator_service, db_session_mock):
    # Setup mock assets
    asset = LivestockAsset(id=1, user_id=1, purchase_price=1000.0)
    calculator_service.repository.get_assets_by_user.return_value = [asset]
    
    # Mock totals from DB queries
    def db_query_scalar_side_effect(*args, **kwargs):
        # We need a predictable sequence or check args
        pass
        
    # Instead of complex query mocking, let's just mock the scalar return values
    # The queries in order: feed, vet, utility, other, earnings
    mock_query = MagicMock()
    mock_filter = MagicMock()
    mock_scalar = MagicMock()
    
    # Values: Feed=100, Vet=50, Utility=0, Other=0, Earnings=1500
    mock_scalar.side_effect = [
        Decimal("100"),  # feed
        Decimal("50"),   # vet
        Decimal("0"),    # utility
        Decimal("0"),    # other
        Decimal("1500")  # earnings
    ]
    
    mock_filter.scalar = mock_scalar
    mock_query.filter.return_value = mock_filter
    db_session_mock.query.return_value = mock_query
    
    # Mock yields
    mock_yield = LivestockYield(asset_id=1, product_sub_type="meat", volume=10, earnings=1500.0)
    mock_filter.all.return_value = [mock_yield]
    
    summary = calculator_service.get_analytics_summary(user_id=1)
    
    # Initial Investment = 1000
    # Operating Expenses = 100 + 50 = 150
    # Total Costs = 1150
    # Total Earnings = 1500
    # Net Profit = 1500 - 1150 = 350
    # ROI = (350 / 1150) * 100 = 30.43%
    
    assert summary.initial_investment == Decimal("1000")
    assert summary.operating_expenses == Decimal("150")
    assert summary.total_costs == Decimal("1150")
    assert summary.total_earnings == Decimal("1500")
    assert summary.net_profit == Decimal("350")
    assert summary.roi == 30.43

def test_get_analytics_summary_zero_costs_edge_case(calculator_service, db_session_mock):
    asset = LivestockAsset(id=1, user_id=1, purchase_price=0.0)
    calculator_service.repository.get_assets_by_user.return_value = [asset]
    
    mock_query = MagicMock()
    mock_filter = MagicMock()
    mock_scalar = MagicMock()
    
    # All costs zero, earnings = 500
    mock_scalar.side_effect = [
        Decimal("0"),  # feed
        Decimal("0"),   # vet
        Decimal("0"),    # utility
        Decimal("0"),    # other
        Decimal("500")  # earnings
    ]
    
    mock_filter.scalar = mock_scalar
    mock_query.filter.return_value = mock_filter
    db_session_mock.query.return_value = mock_query
    
    mock_filter.all.return_value = []
    
    summary = calculator_service.get_analytics_summary(user_id=1)
    
    assert summary.total_costs == Decimal("0")
    assert summary.total_earnings == Decimal("500")
    assert summary.net_profit == Decimal("500")
    assert summary.roi == 0.0  # Division by zero avoided

def test_get_analytics_summary_negative_profit(calculator_service, db_session_mock):
    asset = LivestockAsset(id=1, user_id=1, purchase_price=500.0)
    calculator_service.repository.get_assets_by_user.return_value = [asset]
    
    mock_query = MagicMock()
    mock_filter = MagicMock()
    mock_scalar = MagicMock()
    
    # High costs, low earnings
    mock_scalar.side_effect = [
        Decimal("200"),  # feed
        Decimal("100"),  # vet
        Decimal("0"),    # utility
        Decimal("0"),    # other
        Decimal("100")   # earnings
    ]
    
    mock_filter.scalar = mock_scalar
    mock_query.filter.return_value = mock_filter
    db_session_mock.query.return_value = mock_query
    mock_filter.all.return_value = []
    
    summary = calculator_service.get_analytics_summary(user_id=1)
    
    # Total costs = 500 + 300 = 800
    # Earnings = 100
    # Net profit = 100 - 800 = -700
    # ROI = (-700 / 800) * 100 = -87.5%
    
    assert summary.total_costs == Decimal("800")
    assert summary.net_profit == Decimal("-700")
    assert summary.roi == -87.5
