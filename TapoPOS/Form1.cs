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

                    if (result == null)
                    {
                        MessageBox.Show("Không có ID này!", "Thông báo", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        loginAttempts++;
                    }
                    else if (!VerifyPassword(txtMatKhau.Text, result.ToString()))
                    {
                        MessageBox.Show("Sai mật khẩu!", "Thông báo", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        loginAttempts++;
                    }
                    else
                    {
                        // Lấy loại nhân viên
                        string loaiQuery = "SELECT TenDangNhap FROM [NguoiDung] WHERE TenDangNhap = @TenDangNhap";
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
        private bool VerifyPassword(string password, string storedHash)
        {
            if (string.IsNullOrEmpty(password) || string.IsNullOrEmpty(storedHash))
            {
                return false;
            }

            using (SHA256 sha256Hash = SHA256.Create())
            {
                byte[] bytes = Encoding.UTF8.GetBytes(password);
                byte[] hashBytes = sha256Hash.ComputeHash(bytes);

                string hexHash = BitConverter.ToString(hashBytes).Replace("-", string.Empty);
                if (string.Equals(storedHash, hexHash, StringComparison.OrdinalIgnoreCase))
                {
                    return true;
                }

                string base64Hash = Convert.ToBase64String(hashBytes);
                return string.Equals(storedHash, base64Hash, StringComparison.OrdinalIgnoreCase);
            }
        }
    }
}
