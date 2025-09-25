clc,clear
% 1. Load the dataset into MATLAB using readtable.
%T = readtable('dirty_cafe_sales-1.csv');

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 8);

% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["Var1", "Item", "Quantity", "PricePerUnit", "TotalSpent", "PaymentMethod", "Location", "Var8"];
opts.SelectedVariableNames = ["Item", "Quantity", "PricePerUnit", "TotalSpent", "PaymentMethod", "Location"];
opts.VariableTypes = ["string", "categorical", "double", "double", "double", "categorical", "categorical", "string"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, ["Var1", "Var8"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Var1", "Item", "PaymentMethod", "Location", "Var8"], "EmptyFieldRule", "auto");


% Import the data
T = readtable("C:\Users\ratol\My Drive\School folders\Fall 2025\ENG220\LAB Assigments\Lab 6\dirty_cafe_sales-1.csv", opts)

% 2. Handle missing or invalid values
% Replace strings with 'UNKNOWN and 'ERROR' in the Item, PaymentMethod, and Location columns with '<undefined>'
idx_to_replace_Item = strcmp(T.Item, 'UNKNOWN') | strcmp(T.Item, 'ERROR');
T.Item(idx_to_replace_Item) = {'<undefined>'};

idx_to_replace_PatmentMethod = strcmp(T.PaymentMethod, 'UNKNOWN') | strcmp(T.PaymentMethod, 'ERROR');
T.PaymentMethod(idx_to_replace_PatmentMethod) = {'<undefined>'};

idx_to_replace_Location = strcmp(T.Location, 'UNKNOWN') | strcmp(T.Location, 'ERROR');
T.Location(idx_to_replace_Location) = {'<undefined>'};




%3.  Convert relevant columns to numeric, coercing errors to NaN (missing)
T.Quantity = str2double(string(T.Quantity));
T.PricePerUnit = str2double(string(T.PricePerUnit));
T.TotalSpent = str2double(string(T.TotalSpent));

%. Recalculate Total Spent where missing or inconsistent
idx_recalculate = isnan(T.TotalSpent) | (T.TotalSpent ~= T.Quantity .* T.PricePerUnit);
T.TotalSpent(idx_recalculate) = T.Quantity(idx_recalculate) .* T.PricePerUnit(idx_recalculate);

% 4. Create a cleaned table (Tclean)
% Keep only rows where Total Spent is available after cleaning
Tclean = T(~isnan(T.TotalSpent), :);



% 4. Summary Statistics for Total Spent
totalSpentStats.Count = sum(~isnan(Tclean.TotalSpent));
totalSpentStats.Mean = mean(Tclean.TotalSpent, 'omitnan');
totalSpentStats.StdDev = std(Tclean.TotalSpent, 'omitnan');
totalSpentStats.Min = min(Tclean.TotalSpent, 'omitnan');
totalSpentStats.Median = median(Tclean.TotalSpent, 'omitnan');
totalSpentStats.Max = max(Tclean.TotalSpent, 'omitnan');
totalSpentStats.Sum = sum(Tclean.TotalSpent, 'omitnan');

disp('Summary Statistics for Total Spent:');
disp(totalSpentStats);

% 5. Mostly Sold Item
% Item sold most frequently (by number of transactions)
[itemCounts] = groupcounts(Tclean, 'Item');
[~, idx_mostFrequentItem] = max(itemCounts.GroupCount);
mostFrequentItem = itemCounts.Item{idx_mostFrequentItem};
fprintf('Item sold most frequently (by transactions): %s\n', mostFrequentItem);

% Item sold in the greatest total quantity
itemTotalQuantity = groupsummary(Tclean, 'Item', 'sum', 'Quantity');
[~, idx_greatestQuantity] = max(itemTotalQuantity.sum_Quantity);
greatestQuantityItem = itemTotalQuantity.Item{idx_greatestQuantity};
fprintf('Item sold in greatest total quantity: %s\n', greatestQuantityItem);

% 6. Most Preferred Payment Method
paymentMethodCounts = groupcounts(Tclean, 'PaymentMethod');
[~, idx_mostPreferredPayment] = max(paymentMethodCounts.GroupCount);
mostPreferredPaymentMethod = paymentMethodCounts.PaymentMethod{idx_mostPreferredPayment};
fprintf('Most preferred payment method: %s\n', mostPreferredPaymentMethod);

% 7. Bar Chart of Total Spent per Item
totalSpentPerItem = groupsummary(Tclean, 'Item', 'sum', 'TotalSpent');
figure;
bar(categorical(totalSpentPerItem.Item), totalSpentPerItem.sum_TotalSpent);
title('Total Spent per Item');
xlabel('Item');
ylabel('Total Revenue');

% 8. Bar Chart of Transactions per Item
transactionsPerItem = groupcounts(Tclean, 'Item');
figure;
bar(categorical(transactionsPerItem.Item), transactionsPerItem.GroupCount);
title('Number of Transactions per Item');
xlabel('Item');
ylabel('Number of Transactions');

% 9. Pie Chart of Payment Methods
paymentMethodProportions = groupsummary(Tclean, 'PaymentMethod', 'sum', 'TotalSpent','IncludeMissingGroups', false); % Using TotalSpent for proportions, could also use 'Count'
figure;
pie(paymentMethodProportions.sum_TotalSpent, paymentMethodProportions.PaymentMethod);
title('Proportion of Transactions by Payment Method (by Total Spent)');

% 10. Histogram of Total Spent
figure;
histogram(Tclean.TotalSpent);
title('Distribution of Total Spending per Transaction');
xlabel('Total Spent');
ylabel('Frequency');