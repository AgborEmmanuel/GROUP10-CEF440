import pandas as pd
import numpy as np

def load_data(file_path):
    """
    Load the survey data from an Excel file.
    """
    try:
        df = pd.read_excel(file_path)
        print(" Data loaded successfully.")
        return df
    except Exception as e:
        print(f" Error loading file: {e}")
        return None

def explore_data(df):
    """
    Print basic information and summary statistics of the DataFrame.
    """
    print(" ----- First 5 Rows -----")
    print(df.head(), "\n")
    
    print(" ----- Data Info -----")
    df.info()
    
    print("\n ----- Statistical Summary -----")
    print(df.describe(include='all'))
    
    print("\n ----- Missing Values per Column -----")
    print(df.isnull().sum(), "\n")

def rename_columns(df):
    """
    Rename long survey question headers to concise, friendly names.
    """
    new_columns = {
        "1. How often do you perform regular maintenance on your vehicle?": "Maintenance_Frequency",
        "2. Have you ever experienced difficulties in diagnosing a car issue?": "Diagnosis_Difficulty",
        "3. How do you currently diagnose car issues? (Select all that apply)": "Current_Diagnosis_Methods",
        "4. Have you ever experienced dashboard warning lights on your vehicle?": "Seen_Warning_Lights",
        "5. Which dashboard warning lights do you commonly see? (Select all that apply)": "Common_Warning_Lights",
        "6. How confident are you in interpreting dashboard warning lights?": "Warning_Light_Confidence",
        "7. When a warning light appears, what is your typical course of action?": "Warning_Light_Action",
        "8. Have you ever delayed maintenance because you were unsure of the significance of a warning light?": "Delayed_Maintenance",
        "9. What do you typically do if you hear an unusual engine sound?": "Unusual_Sound_Action",
        "10. Have you used any apps or devices (like an OBD-II scanner) to diagnose car issues?": "Used_Diagnostic_Tools",
        "11. How likely are you to use a mobile app that can diagnose dashboard warning lights using your phone camera and analyze engine sounds for diagnostic purposes?": "Willingness_to_Use_App",
        "12. Which features would you find most valuable in a car fault diagnosis app? (Rank in order of importance)": "Valuable_App_Features",
        "13. How important is it for you to receive automated repair suggestions based on detected issues?": "Importance_of_Repair_Suggestions",
        "14. What types of multimedia content would you prefer for learning about repairs? (Select all that apply)": "Preferred_Repair_Content",
        "15. What mobile operating system do you use?": "Mobile_OS",
        "16. Would you be comfortable using an app that requires access to your camera and microphone for diagnostic purposes?": "Comfort_with_App_Access",
        "17. What feature would be most valuable to you in a car diagnostic app?": "Most_Valuable_Feature",
        "18. What concerns do you have about using a mobile app for car diagnostics? (Select all that apply)": "App_Concerns",
        "19. What additional features would you like to see in a car fault diagnosis app? (Open-ended)": "Suggested_Additional_Features"
    }
    df = df.rename(columns=new_columns)
    print(" Columns renamed for clarity.")
    return df

def clean_text_columns(df):
    """
    Clean whitespace and formatting issues in object columns.
    """
    for col in df.select_dtypes(include='object').columns:
        # Convert to string, remove extra whitespace/newlines and set to lower case
        df[col] = df[col].astype(str).str.strip().str.replace('\n', ' ').str.lower()
    print(" Cleaned text columns (whitespace removed, lowercased, newlines removed).")
    return df

def handle_missing(df):
    """
    Drop rows with missing critical values and fill non-critical missing values with a placeholder.
    """
    initial_rows = len(df)
    # Define critical columns; adjust as needed.
    critical_fields = ["Maintenance_Frequency", "Willingness_to_Use_App"]
    df = df.dropna(subset=critical_fields)
    print(f" Dropped rows with missing critical fields: Rows before = {initial_rows}, after = {len(df)}.")
    
    # For non-critical missing values, fill with a placeholder.
    df.fillna("not_specified", inplace=True)
    return df

def remove_duplicates(df):
    """
    Remove duplicate rows from the DataFrame.
    """
    num_duplicates = df.duplicated().sum()
    if num_duplicates > 0:
        print(f" Found {num_duplicates} duplicate rows. Removing duplicates.")
        df = df.drop_duplicates()
    else:
        print(" No duplicate rows found.")
    return df

def correct_data_types(df):
    """
    Correct column data types where necessary.
    """
    # Example: Convert 'Timestamp' column to datetime if present.
    if 'Timestamp' in df.columns:
        try:
            df['Timestamp'] = pd.to_datetime(df['Timestamp'], errors='coerce')
            print(" Converted 'Timestamp' column to datetime.")
        except Exception as e:
            print(f" Error converting 'Timestamp': {e}")

    # Example: If there is a 'Rating' column, convert to numeric.
    if 'Rating' in df.columns:
        df['Rating'] = pd.to_numeric(df['Rating'], errors='coerce')
        if df['Rating'].isnull().sum() > 0:
            df['Rating'].fillna(df['Rating'].mean(), inplace=True)
        print(" Converted 'Rating' column to numeric.")

    return df

def remove_outliers(df, column_name, m=3):
    """
    Remove outliers from a numeric column that are beyond m standard deviations from the mean.
    """
    if column_name in df.columns and np.issubdtype(df[column_name].dtype, np.number):
        mean = df[column_name].mean()
        std = df[column_name].std()
        before_count = df.shape[0]
        df = df[np.abs(df[column_name] - mean) < m * std]
        after_count = df.shape[0]
        print(f" Removed outliers from '{column_name}': {before_count - after_count} rows removed.")
    return df

def split_multiselect_columns(df, columns_to_split):
    """
    Convert comma-separated multi-select responses into list format.
    """
    for col in columns_to_split:
        if col in df.columns:
            df[col] = df[col].apply(lambda x: [item.strip() for item in x.split(',')] if isinstance(x, str) else [])
    print(" Converted multi-select columns into list format.")
    return df

def save_cleaned_data(df, path):
    """
    Save the cleaned DataFrame to a CSV file.
    """
    try:
        df.to_csv(path, index=False)
        print(f" Cleaned data saved to {path}")
    except Exception as e:
        print(f" Error saving cleaned data: {e}")

if __name__ == "__main__":
    # Set file paths (update as needed)
    input_file_path = "C:/Users/Abila/Desktop/FET-L400-2ND/GROUP10-CEF440/response sheet.xlsx"
    output_file_path = "C:/Users/Abila/Desktop/FET-L400-2ND/GROUP10-CEF440/cleaned_survey_data.csv"
    
    # Step 1: Data Loading
    df = load_data(input_file_path)
    if df is None:
        raise SystemExit(" Failed to load data. Exiting.")
    
    # Step 2: Data Exploration
    print("=== Initial Data Exploration ===")
    explore_data(df)
    
    # Step 3: Rename Columns
    df = rename_columns(df)
    
    # Step 4: Clean Text Columns (whitespace, newlines, case standardization)
    df = clean_text_columns(df)
    
    # Step 5: Handle Missing Values (drop critical and fill non-critical missing)
    df = handle_missing(df)
    
    # Step 6: Remove Duplicate Records
    df = remove_duplicates(df)
    
    # Step 7: Data Type Corrections (convert Timestamp and any numeric fields)
    df = correct_data_types(df)
    
    # Step 8: Outlier Detection and Removal (example: remove outliers in a 'Rating' column if exists)
    # Uncomment and modify the following line if you have a numeric column (e.g., "Rating")
    # df = remove_outliers(df, "Rating", m=3)
    
    # Step 9: Handle Multi-Select Fields (convert responses to list format)
    multiselect_columns = [
        "Current_Diagnosis_Methods", "Common_Warning_Lights", 
        "Preferred_Repair_Content", "App_Concerns"
    ]
    df = split_multiselect_columns(df, multiselect_columns)
    
    # Step 10: Final Data Exploration after cleaning
    print("=== Data Summary After Cleaning ===")
    explore_data(df)
    
    # Step 11: Save the Clean Data
    save_cleaned_data(df, output_file_path)
