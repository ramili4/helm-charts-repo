import yaml

# Load index.yaml from your charts directory
with open('charts/index.yaml', 'r') as index_file:
    index_data = yaml.safe_load(index_file)

charts = []

for chart_name, versions in index_data.get('entries', {}).items():
    if versions:
        # Take the latest version only (you can adjust this logic)
        latest = sorted(versions, key=lambda v: v['version'], reverse=True)[0]
        charts.append({
            'name': chart_name,
            'version': latest['version']
        })

# Save as charts.yaml
with open('charts/chart-data/charts.yaml', 'w') as out_file:
    yaml.dump({'charts': charts}, out_file, default_flow_style=False)

print("✅ charts.yaml generated.")

