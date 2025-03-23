import 'package:events_emitter/events_emitter.dart';
import 'package:expense_advisor/bloc/cubit/app_cubit.dart';
import 'package:expense_advisor/dao/account_dao.dart';
import 'package:expense_advisor/dao/payment_dao.dart';
import 'package:expense_advisor/events.dart';
import 'package:expense_advisor/model/account.model.dart';
import 'package:expense_advisor/model/category.model.dart';
import 'package:expense_advisor/model/payment.model.dart';
import 'package:expense_advisor/screens/home/widgets/account_slider.dart';
import 'package:expense_advisor/screens/home/widgets/expense_chart.dart';
import 'package:expense_advisor/screens/home/widgets/payment_list_item.dart';
import 'package:expense_advisor/screens/payment_form.screen.dart';
import 'package:expense_advisor/theme/colors.dart';
import 'package:expense_advisor/widgets/currency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:expense_advisor/screens/home/widgets/travel_mode_toggle.dart';
import 'package:flutter/services.dart';

String greeting() {
  var hour = DateTime.now().hour;
  if (hour < 12) {
    return 'Morning';
  }
  if (hour < 17) {
    return 'Afternoon';
  }
  return 'Evening';
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final PaymentDao _paymentDao = PaymentDao();
  final AccountDao _accountDao = AccountDao();
  EventListener? _accountEventListener;
  EventListener? _categoryEventListener;
  EventListener? _paymentEventListener;
  List<Payment> _payments = [];
  List<Account> _accounts = [];
  double _income = 0;
  double _expense = 0;

  DateTimeRange _range = DateTimeRange(
    start: DateTime.now().subtract(Duration(days: DateTime.now().day - 1)),
    end: DateTime.now(),
  );
  Account? _account;
  Category? _category;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = true;

  void openAddPaymentPage(PaymentType type) async {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => PaymentForm(type: type),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = const Offset(0.0, 1.0);
          var end = Offset.zero;
          var curve = Curves.easeOutQuint;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  void handleChooseDateRange() async {
    final selected = await showDateRangePicker(
      context: context,
      initialDateRange: _range,
      firstDate: DateTime(2019),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ThemeColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );
    if (selected != null) {
      setState(() {
        _range = selected;
        _fetchTransactions();
      });
    }
  }

  void _fetchTransactions() async {
    setState(() {
      _isLoading = true;
    });

    List<Payment> trans = await _paymentDao.find(
      range: _range,
      category: _category,
      account: _account,
    );
    double income = 0;
    double expense = 0;
    for (var payment in trans) {
      if (payment.type == PaymentType.credit) income += payment.amount;
      if (payment.type == PaymentType.debit) expense += payment.amount;
    }

    List<Account> accounts = await _accountDao.find(withSummery: true);

    setState(() {
      _payments = trans;
      _income = income;
      _expense = expense;
      _accounts = accounts;
      _isLoading = false;
    });

    _animationController.forward(from: 0.0);
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _fetchTransactions();

    _accountEventListener = globalEvent.on("account_update", (data) {
      debugPrint("accounts are changed");
      _fetchTransactions();
    });

    _categoryEventListener = globalEvent.on("category_update", (data) {
      debugPrint("categories are changed");
      _fetchTransactions();
    });

    _paymentEventListener = globalEvent.on("payment_update", (data) {
      debugPrint("payments are changed");
      _fetchTransactions();
    });
  }

  @override
  void dispose() {
    _accountEventListener?.cancel();
    _categoryEventListener?.cancel();
    _paymentEventListener?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: () async {
          _fetchTransactions();
        },
        color: ThemeColors.primary,
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: child,
                      ),
                    );
                  },
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverAppBar(
                        expandedHeight: 120.0,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        pinned: false,
                        floating: true,
                        flexibleSpace: FlexibleSpaceBar(
                          background: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  ThemeColors.primary.withOpacity(0.1),
                                  Colors.transparent,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "Good ${greeting()},",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                BlocConsumer<AppCubit, AppState>(
                                  listener: (context, state) {},
                                  builder:
                                      (context, state) => Text(
                                        state.username ?? "Guest",
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                ),
                                const SizedBox(height: 15),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const TravelModeToggle(),
                              const SizedBox(height: 20),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Your Accounts",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                        ),
                                        iconSize: 20,
                                        color: ThemeColors.primary,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: AccountsSlider(accounts: _accounts),
                      ),
                      SliverToBoxAdapter(child: const SizedBox(height: 25)),

                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Monthly Overview",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: handleChooseDateRange,
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: ThemeColors.primary.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            "${DateFormat("dd MMM").format(_range.start)} - ${DateFormat("dd MMM").format(_range.end)}",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: ThemeColors.primary,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Icon(
                                            Icons.calendar_today_rounded,
                                            size: 14,
                                            color: ThemeColors.primary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: ThemeColors.success.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: ThemeColors.success
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: const Icon(
                                                  Icons.arrow_downward_rounded,
                                                  color: ThemeColors.success,
                                                  size: 16,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Text(
                                                "Income",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          CurrencyText(
                                            _income,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w800,
                                              color: ThemeColors.success,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: ThemeColors.error.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: ThemeColors.error
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: const Icon(
                                                  Icons.arrow_upward_rounded,
                                                  color: ThemeColors.error,
                                                  size: 16,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Text(
                                                "Expense",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          CurrencyText(
                                            _expense,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w800,
                                              color: ThemeColors.error,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              ExpenseChart(dateRange: _range),
                            ],
                          ),
                        ),
                      ),

                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            top: 25,
                            bottom: 10,
                          ),
                          child: Row(
                            children: [
                              Text(
                                "Recent Transactions",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const Spacer(),
                              if (_payments.isNotEmpty)
                                TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    "View All",
                                    style: TextStyle(
                                      color: ThemeColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      _payments.isNotEmpty
                          ? SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.03),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: PaymentListItem(
                                      payment: _payments[index],
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder:
                                                (builder) => PaymentForm(
                                                  type: _payments[index].type,
                                                  payment: _payments[index],
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                              childCount:
                                  _payments.length > 5 ? 5 : _payments.length,
                            ),
                          )
                          : SliverToBoxAdapter(
                            child: Container(
                              padding: const EdgeInsets.all(30),
                              margin: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.receipt_long_outlined,
                                    size: 50,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 15),
                                  Text(
                                    "No transactions yet",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "Add your first transaction by tapping the + button",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                      const SliverToBoxAdapter(child: SizedBox(height: 80)),
                    ],
                  ),
                ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openAddPaymentPage(PaymentType.debit),

        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          "Add Transaction",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
