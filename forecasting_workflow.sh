curl https://www.mtggoldfish.com/price/Onslaught/Polluted+Delta#paper --output pd.txt

grep -n '"graphdiv-paper"' pd.txt | cut -d : -f 1 > line.txt

sed -n 1,"$(< line.txt)"p pd.txt > pd2.txt

rm pd.txt

rm line.txt

grep -n '  d += ' pd2.txt > pd.txt

rm pd2.txt

Rscript mtg_price.R

git add mtg_price.pdf
git commit -m "New daily projection"
git push
