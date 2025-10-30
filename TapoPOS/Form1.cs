using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Security.Cryptography;
namespace TapoPOS
{
    public partial class Form1 : Form
    {
        private int loginAttempts = 0; // Đếm số lần nhập sai
        public Form1()
        {
            InitializeComponent();
        }

        private void label1_Click(object sender, EventArgs e)
        {

        }

        private void btnLogin_Click(object sender, EventArgs e)
        {
            //ktr đầy đủ
            if (txtTenDN.Text == string.Empty)
            {
                MessageBox.Show("Hãy nhập vào tài khoản", "Thông báo", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                txtTenDN.Focus();
                return;
            }
            if (txtMatKhau.Text == string.Empty)
            {
                MessageBox.Show("Hãy nhập vào mật khẩu", "Thông báo", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                txtMatKhau.Focus();
                return;
            }
            //ktr tên đăng nhập có hợp lệ không
            string connString = "Data Source=DESKTOP-1OUP7MA\\SQLEXPRESS;Initial Catalog=QLCUAHANGTAPHOA;Integrated Security=True;Encrypt=False";
            using (SqlConnection conn = new SqlConnection(connString))
            {
                try
                {
                    conn.Open();
                    string query = "SELECT MatkhauHash FROM [NguoiDung] WHERE TenDangNhap = @TenDangNhap";
                    SqlCommand cmd = new SqlCommand(query, conn);
                    cmd.Parameters.AddWithValue("@TenDangNhap", txtTenDN.Text);

                    object result = cmd.ExecuteScalar();
                    byte[] storedHash = ParseStoredHash(result);

                    if (storedHash == null)
                    {
                        MessageBox.Show("Không có ID này!", "Thông báo", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        loginAttempts++;
                    }
                    else if (!VerifyPassword(txtMatKhau.Text, storedHash))
                    {
                        MessageBox.Show("Sai mật khẩu!", "Thông báo", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        loginAttempts++;
                    }
                    else
                    {
                        // Lấy loại nhân viên
                        string loaiQuery = "SELECT VaiTro FROM [NguoiDung] WHERE TenDangNhap = @TenDangNhap";
                        SqlCommand loaiCmd = new SqlCommand(loaiQuery, conn);
                        loaiCmd.Parameters.AddWithValue("@TenDangNhap", txtTenDN.Text);
                        object loaiResult = loaiCmd.ExecuteScalar();
                        string LoaiNV = loaiResult != null ? loaiResult.ToString() : "Không rõ";

                        MessageBox.Show("Đăng nhập thành công!", "Thông báo", MessageBoxButtons.OK, MessageBoxIcon.Information);

                        //// Truyền loại nhân viên sang form chính
                        //SweetMomentsApp mainForm = (SweetMomentsApp)Application.OpenForms["SweetMomentsApp"];
                        //if (mainForm != null)
                        //{
                        //    mainForm.XuLyDangNhapThanhCong(LoaiNV); // Truyền LoaiNV
                        //}

                        this.Close(); // Đóng form đăng nhập
                        return;
                    }

                    if (loginAttempts >= 3)
                    {
                        MessageBox.Show("Bạn đã nhập sai quá 3 lần, hệ thống sẽ tự động đóng!", "Cảnh báo", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                        this.Close();
                    }
                }
                catch (Exception ex)
                {
                    MessageBox.Show("Lỗi kết nối CSDL: " + ex.Message, "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            Application.Exit();
        }

        private void label2_Click(object sender, EventArgs e)
        {

        }
        private byte[] ParseStoredHash(object dbValue)
        {
            if (dbValue == null || dbValue is DBNull)
            {
                return null;
            }

            if (dbValue is byte[] bytes && bytes.Length > 0)
            {
                return bytes;
            }

            string stringValue = dbValue.ToString();
            if (string.IsNullOrWhiteSpace(stringValue))
            {
                return null;
            }

            stringValue = stringValue.Trim();

            if (stringValue.StartsWith("0x", StringComparison.OrdinalIgnoreCase))
            {
                stringValue = stringValue.Substring(2);
            }

            if (IsHexString(stringValue))
            {
                int numberChars = stringValue.Length;
                byte[] hexBytes = new byte[numberChars / 2];
                for (int i = 0; i < numberChars; i += 2)
                {
                    hexBytes[i / 2] = Convert.ToByte(stringValue.Substring(i, 2), 16);
                }
                return hexBytes;
            }

            try
            {
                return Convert.FromBase64String(stringValue);
            }
            catch (FormatException)
            {
                return null;
            }
        }

        private bool IsHexString(string value)
        {
            if (value.Length % 2 != 0)
            {
                return false;
            }

            for (int i = 0; i < value.Length; i++)
            {
                char c = value[i];
                bool isHexDigit = (c >= '0' && c <= '9') ||
                                  (c >= 'a' && c <= 'f') ||
                                  (c >= 'A' && c <= 'F');
                if (!isHexDigit)
                {
                    return false;
                }
            }

            return true;
        }

        private bool VerifyPassword(string password, byte[] storedHash)
        {
            if (string.IsNullOrEmpty(password) || storedHash == null || storedHash.Length == 0)
            {
                return false;
            }

            using (SHA256 sha256Hash = SHA256.Create())
            {
                byte[] bytes = Encoding.UTF8.GetBytes(password);
                byte[] hashBytes = sha256Hash.ComputeHash(bytes);
                if (hashBytes.Length != storedHash.Length)
                {
                    return false;
                }
                for (int i = 0; i < hashBytes.Length; i++)
                {
                    if (hashBytes[i] != storedHash[i])
                    {
                        return false;
                    }
                }

                return true;
            }
        }
    }
}
