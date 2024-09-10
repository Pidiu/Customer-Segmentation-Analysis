# Customer-Segmentation-Analysis
1. Mục tiêu:
Xác định phân khúc khách hàng cho hóa đơn tiền điện, từ đó đưa ra kế hoạch marketing phù hợp giúp tối ưu kinh phí.
2. Công cụ:
Sử dụng công cụ TSql để tiến hành tính toán RFM ( Retention - Frequency - Monetary) cho từng khách hàng và sử dụng percentile để chia các phân khúc khách hàng.
3. Kết quả:
Xác định được 9 nhóm khách hàng theo tổ hợp hành vi. Từ đó tiến hành chiến lược phát voucher tri ân tối ưu cho các nhóm chính:
- Khách hàng tốt: có thể voucher giá trị thấp (vì họ vẫn sẽ tiếp tục mua hàng của mình)
- Khách hàng tiềm năng: voucher cao hơn nhóm khách hàng tốt
- Khách hàng ngủ đông: voucher cao hơn nhóm khách hàng tốt 
- Khách hàng xấu: không phát voucher, nên tìm hiểu thêm nguyên nhân nhóm khách này rời bỏ mình 
